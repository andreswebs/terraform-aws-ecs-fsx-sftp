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

locals {

  ssm_param_arn_prefix = "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter"

  sftp_ssm_param_user_pub_key  = "${var.sftp_ssm_param_prefix}${var.sftp_ssm_param_user_pub_key}"
  sftp_ssm_param_host_pub_key  = "${var.sftp_ssm_param_prefix}${var.sftp_ssm_param_host_pub_key}"
  sftp_ssm_param_host_priv_key = "${var.sftp_ssm_param_prefix}${var.sftp_ssm_param_host_priv_key}"

  ssm_param_arn_user_pub_key  = "${local.ssm_param_arn_prefix}${local.sftp_ssm_param_user_pub_key}"
  ssm_param_arn_host_pub_key  = "${local.ssm_param_arn_prefix}${local.sftp_ssm_param_host_pub_key}"
  ssm_param_arn_host_priv_key = "${local.ssm_param_arn_prefix}${local.sftp_ssm_param_host_priv_key}"

  fsx_ssm_param_domain   = "${var.fsx_ssm_param_prefix}${var.fsx_ssm_param_domain}"
  fsx_ssm_param_username = "${var.fsx_ssm_param_prefix}${var.fsx_ssm_param_username}"
  fsx_ssm_param_password = "${var.fsx_ssm_param_prefix}${var.fsx_ssm_param_password}"

  ssm_param_arn_fsx_domain   = "${local.ssm_param_arn_prefix}${local.fsx_ssm_param_domain}"
  ssm_param_arn_fsx_username = "${local.ssm_param_arn_prefix}${local.fsx_ssm_param_username}"
  ssm_param_arn_fsx_password = "${local.ssm_param_arn_prefix}${local.fsx_ssm_param_password}"

}

locals {
  create_instance_role  = var.instance_role_arn == "" || var.instance_role_arn == null
  create_execution_role = var.execution_role_arn == "" || var.execution_role_arn == null
  create_task_role      = var.task_role_arn == "" || var.task_role_arn == null
}

module "iam" {

  source = "./modules/iam"

  create_instance_role  = local.create_instance_role
  create_execution_role = local.create_execution_role
  create_task_role      = local.create_task_role

  instance_profile_name = var.instance_profile_name
  instance_role_name    = var.instance_role_name
  execution_role_name   = var.execution_role_name
  task_role_name        = var.task_role_name

  ssm_param_arn_host_priv_key     = local.ssm_param_arn_host_priv_key
  ssm_param_arn_host_pub_key      = local.ssm_param_arn_host_pub_key
  ssm_param_arn_user_pub_key      = local.ssm_param_arn_user_pub_key
  ssm_param_arn_config_users_conf = aws_ssm_parameter.sftp_config_users_conf.arn
  ssm_param_arn_fsx_domain        = local.ssm_param_arn_fsx_domain
  ssm_param_arn_fsx_username      = local.ssm_param_arn_fsx_username
  ssm_param_arn_fsx_password      = local.ssm_param_arn_fsx_password

}

locals {

  fsx_config_command = templatefile("${path.module}/tpl/fsx-config.cmd.tftpl", {
    fsx_mount_point = var.fsx_mount_point
    sftp_users      = local.sftp_users
    sftp_uid_start  = var.sftp_uid_start
  })

  fsx_get_creds_command = templatefile("${path.module}/tpl/fsx-get-creds.cmd.tftpl", {
    fsx_creds_path         = var.fsx_creds_path
    fsx_ssm_param_domain   = local.fsx_ssm_param_domain
    fsx_ssm_param_username = local.fsx_ssm_param_username
    fsx_ssm_param_password = local.fsx_ssm_param_password
  })

  fsx_mount_command = templatefile("${path.module}/tpl/fsx-mount.cmd.tftpl", {
    sftp_users            = local.sftp_users
    sftp_uid_start        = var.sftp_uid_start
    fsx_ip_address        = var.fsx_ip_address
    fsx_file_share        = var.fsx_file_share
    fsx_mount_point       = var.fsx_mount_point
    fsx_smb_version       = var.fsx_smb_version
    fsx_cifs_max_buf_size = var.fsx_cifs_max_buf_size
    fsx_creds_path        = var.fsx_creds_path
  })

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

  user_data = base64encode(templatefile("${path.module}/tpl/userdata.tftpl", {
    cluster_name          = var.cluster_name
    fsx_config_command    = local.fsx_config_command
    fsx_get_creds_command = local.fsx_get_creds_command
    fsx_mount_command     = local.fsx_mount_command
  }))

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

  capacity_providers = [aws_ecs_capacity_provider.this.name]

  ## Bug (as of 2021-12-18): 
  ## https://github.com/hashicorp/terraform-provider-aws/issues/11409
  provisioner "local-exec" {
    when = destroy

    command = <<CMD
      # Get the list of capacity providers associated with this cluster
      CAP_PROVS="$(aws ecs describe-clusters --clusters "${self.arn}" \
        --query 'clusters[*].capacityProviders[*]' --output text)"

      # Now get the list of autoscaling groups from those capacity providers
      ASG_ARNS="$(aws ecs describe-capacity-providers \
        --capacity-providers "$CAP_PROVS" \
        --query 'capacityProviders[*].autoScalingGroupProvider.autoScalingGroupArn' \
        --output text)"

      if [ -n "$ASG_ARNS" ] && [ "$ASG_ARNS" != "None" ]
      then
        for ASG_ARN in $ASG_ARNS
        do
          ASG_NAME=$(echo $ASG_ARN | cut -d/ -f2-)

          # Remove scale-in protection from all instances in the asg
          INSTANCES="$(aws autoscaling describe-auto-scaling-groups \
            --auto-scaling-group-names "$ASG_NAME" \
            --query 'AutoScalingGroups[*].Instances[*].InstanceId' \
            --output text)"
          aws autoscaling set-instance-protection --instance-ids $INSTANCES \
            --auto-scaling-group-name "$ASG_NAME" \
            --no-protected-from-scale-in

          # Set the autoscaling group size to zero
          aws autoscaling update-auto-scaling-group \
            --auto-scaling-group-name "$ASG_NAME" \
            --min-size 0 --max-size 0 --desired-capacity 0
        done
      fi
    CMD
  }

}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.cluster_name}"
  retention_in_days = var.log_retention_in_days
}

locals {

  sftp_config_secrets = templatefile("${path.module}/tpl/sftp-config-secrets.json.tftpl", {
    ssm_param_arn_user_pub_key  = local.ssm_param_arn_user_pub_key
    ssm_param_arn_host_pub_key  = local.ssm_param_arn_host_pub_key
    ssm_param_arn_host_priv_key = local.ssm_param_arn_host_priv_key
    ssm_param_arn_users_conf    = aws_ssm_parameter.sftp_config_users_conf.arn
    sftp_users                  = local.sftp_users
  })

  sftp_config_command = templatefile("${path.module}/tpl/sftp-config-cmd.json.tftpl", {
    volume_name_user    = var.sftp_volume_name_user
    volume_name_host    = var.sftp_volume_name_host
    volume_name_config  = var.sftp_volume_name_config
    volume_name_scripts = var.sftp_volume_name_scripts
    sftp_users          = local.sftp_users
  })

  sftp_container_definitions = templatefile("${path.module}/tpl/sftp-container-definitions.json.tftpl", {
    aws_region             = data.aws_region.current.name
    log_group_name         = aws_cloudwatch_log_group.this.name
    main_container_name    = "sftp"
    main_container_image   = var.sftp_main_container_image
    config_container_name  = "sftp-config"
    config_container_image = var.sftp_config_container_image
    config_secrets         = local.sftp_config_secrets
    config_command         = local.sftp_config_command
    volume_name_storage    = var.sftp_volume_name_storage
    volume_name_user       = var.sftp_volume_name_user
    volume_name_host       = var.sftp_volume_name_host
    volume_name_config     = var.sftp_volume_name_config
    volume_name_scripts    = var.sftp_volume_name_scripts
    task_port              = var.sftp_task_port
    host_port              = var.sftp_host_port
    sftp_users             = local.sftp_users
  })

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
