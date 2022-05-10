data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_ami" "ecs_ami_latest" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

data "aws_s3_bucket" "script" {
  bucket = var.script_s3_bucket
}

locals {

  sftp_users = split(",", var.sftp_users)

  ecs_security_group_ids = [
    aws_security_group.internal.id,
    aws_security_group.egress.id,
    aws_security_group.ssh.id,
    aws_security_group.sftp.id
  ]

  ami_id = var.ami_id == null || var.ami_id == "" ? data.aws_ami.ecs_ami_latest.id : var.ami_id

}

resource "aws_launch_template" "this" {
  name                   = "ecs-${var.cluster_name}"
  description            = "Launch template for ECS cluster ${var.cluster_name}"
  update_default_version = true

  instance_type = var.instance_type

  monitoring {
    enabled = true
  }

  image_id = local.ami_id

  vpc_security_group_ids = local.ecs_security_group_ids

  key_name = var.ssh_key_name

  iam_instance_profile {
    name = local.create_instance_role ? module.iam.instance_profile.name : var.instance_role_name
  }

  user_data = local.user_data

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ecs-${var.cluster_name}-node"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {

  name = "ecs-${var.cluster_name}-asg"

  vpc_zone_identifier = var.subnet_ids

  desired_capacity = var.cluster_desired_capacity
  max_size         = var.cluster_max_size
  min_size         = var.cluster_min_size

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

}

resource "aws_ecs_capacity_provider" "this" {
  name = var.cluster_name

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.this.arn

    managed_scaling {
      status                    = "DISABLED"
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

}


resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.this.name]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.cluster_name}"
  retention_in_days = var.log_retention_in_days
}


resource "aws_ecs_task_definition" "this" {

  family                   = "sftp"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = local.create_execution_role ? module.iam.role.ecs_execution.arn : var.execution_role_arn
  task_role_arn            = local.create_task_role ? module.iam.role.ecs_task.arn : var.task_role_arn
  container_definitions    = local.sftp_container_definitions

  dynamic "volume" {
    for_each = local.sftp_users
    iterator = user
    content {
      name      = "${var.sftp_volume_name_storage}-${user.value}"
      host_path = "${var.fsx_mount_point}/${user.value}"
    }
  }

  dynamic "volume" {
    for_each = local.sftp_users
    iterator = user
    content {
      name = "${var.sftp_volume_name_user}-${user.value}"
    }
  }

  volume {
    name = var.sftp_volume_name_host
  }

  volume {
    name = var.sftp_volume_name_config
  }

  volume {
    name = var.sftp_volume_name_scripts
  }

}

resource "aws_ecs_service" "this" {
  name            = "sftp"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn

  enable_ecs_managed_tags = true
  enable_execute_command  = true

  scheduling_strategy = "DAEMON"

}
