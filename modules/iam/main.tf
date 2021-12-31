/**
* Deploys IAM resources for terraform-aws-ecs-fsx-sftp.
*/

/**
* Trust policy used by both the ECS 'Task Execution Role' and 'Task Role'
*/
data "aws_iam_policy_document" "ecs_tasks_trust" {
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
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_trust.json
}

data "aws_iam_policy_document" "ssm_messages" {
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
  source_policy_documents = [
    data.aws_iam_policy_document.ssm_messages.json,
    data.aws_iam_policy_document.access_secrets_sftp.json
  ]
}

resource "aws_iam_role_policy" "ecs_execution_permissions_sftp" {
  count  = var.create_execution_role ? 1 : 0
  name   = "execution-permissions"
  role   = aws_iam_role.ecs_execution[0].name
  policy = data.aws_iam_policy_document.ecs_execution_permissions_sftp.json
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
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_trust.json
}
