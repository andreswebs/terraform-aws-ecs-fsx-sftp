/**
* Deploys IAM resources for terraform-aws-ecs-fsx-sftp.
*/

/**
* Trust policy used by both the ECS 'Task Execution Role' and 'Task Role'
*/
data "aws_iam_policy_document" "ecs_tasks_trust" {
  count = var.create_execution_role || var.create_task_role ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

/**
* ECS 'Task Execution Role' and permissions
*/
resource "aws_iam_role" "ecs_execution" {
  count              = var.create_execution_role ? 1 : 0
  name               = var.execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_trust[0].json
}

data "aws_iam_policy_document" "ssm_messages" {
  count = var.create_execution_role ? 1 : 0
  statement {
    sid = "ssmmessages"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "access_secrets_sftp" {
  count = var.create_execution_role ? 1 : 0
  statement {
    sid = "get"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = [
      "${var.ssm_param_arn_user_pub_key}/*",
      var.ssm_param_arn_host_pub_key,
      var.ssm_param_arn_host_priv_key,
      var.ssm_param_arn_config_users_conf,
    ]
  }
}

data "aws_iam_policy_document" "ecs_execution_permissions_sftp" {
  count = var.create_execution_role ? 1 : 0
  source_policy_documents = [
    data.aws_iam_policy_document.ssm_messages[0].json,
    data.aws_iam_policy_document.access_secrets_sftp[0].json
  ]
}

resource "aws_iam_role_policy" "ecs_execution_permissions_sftp" {
  count  = var.create_execution_role ? 1 : 0
  name   = "execution-permissions"
  role   = aws_iam_role.ecs_execution[0].name
  policy = data.aws_iam_policy_document.ecs_execution_permissions_sftp[0].json
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_sftp" {
  count      = var.create_execution_role ? 1 : 0
  role       = aws_iam_role.ecs_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

/**
* ECS 'Task Role'
*/
resource "aws_iam_role" "ecs_task" {
  count              = var.create_task_role ? 1 : 0
  name               = var.task_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_trust[0].json
}

/**
* ECS container instance role and permissions
*/
data "aws_iam_policy_document" "ec2_trust" {
  count = var.create_instance_role ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_instance" {
  count              = var.create_instance_role ? 1 : 0
  name               = var.instance_role_name
  assume_role_policy = data.aws_iam_policy_document.ec2_trust[0].json
}

resource "aws_iam_instance_profile" "ecs_instance" {
  count = var.create_instance_role ? 1 : 0
  name  = var.instance_profile_name
  role  = aws_iam_role.ecs_instance[0].name
}

locals {

  ecs_instance_policies = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  ]

  ecs_instance_policies_norm = var.create_instance_role ? local.ecs_instance_policies : []

}

resource "aws_iam_role_policy_attachment" "ecs_instance" {
  for_each   = toset(local.ecs_instance_policies_norm)
  role       = aws_iam_role.ecs_instance[0].name
  policy_arn = each.value
}

data "aws_iam_policy_document" "access_secrets_fsx" {
  count = var.create_instance_role ? 1 : 0
  statement {
    sid = "get"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = [
      "${var.ssm_param_arn_fsx_domain}",
      "${var.ssm_param_arn_fsx_username}",
      "${var.ssm_param_arn_fsx_password}",
      "${var.ssm_param_arn_fsx_ip_address}",
    ]
  }
}

resource "aws_iam_role_policy" "ecs_instance_access_secrets_fsx" {
  count  = var.create_instance_role ? 1 : 0
  name   = "fsx-secrets"
  role   = aws_iam_role.ecs_instance[0].name
  policy = data.aws_iam_policy_document.access_secrets_fsx[0].json
}

data "aws_iam_policy_document" "access_script" {
  count = var.create_instance_role ? 1 : 0
  statement {
    sid = "getobject"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${var.script_s3_bucket_arn}/${var.script_s3_key}"
    ]
  }
}

resource "aws_iam_role_policy" "ecs_instance_access_script" {
  count  = var.create_instance_role ? 1 : 0
  name   = "fsx-config-script"
  role   = aws_iam_role.ecs_instance[0].name
  policy = data.aws_iam_policy_document.access_script[0].json
}
