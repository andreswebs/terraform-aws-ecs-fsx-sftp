module "iam" {
  source                          = "github.com/andreswebs/terraform-aws-ecs-fsx-sftp//modules/iam"
  task_role_name                  = var.task_role_name
  execution_role_name             = var.execution_role_name
  ssm_param_arn_user_pub_key      = var.ssm_param_arn_user_pub_key
  ssm_param_arn_host_pub_key      = var.ssm_param_arn_host_pub_key
  ssm_param_arn_host_priv_key     = var.ssm_param_arn_host_priv_key
  ssm_param_arn_config_users_conf = var.ssm_param_arn_config_users_conf
}