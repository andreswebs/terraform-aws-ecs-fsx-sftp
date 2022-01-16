module "iam" {
  source                          = "github.com/andreswebs/terraform-aws-ecs-fsx-sftp//modules/iam"
  task_role_name                  = var.task_role_name
  execution_role_name             = var.execution_role_name
  instance_role_name              = var.instance_role_name
  instance_profile_name           = var.instance_profile_name
  ssm_param_arn_user_pub_key      = var.ssm_param_arn_user_pub_key
  ssm_param_arn_host_pub_key      = var.ssm_param_arn_host_pub_key
  ssm_param_arn_host_priv_key     = var.ssm_param_arn_host_priv_key
  ssm_param_arn_config_users_conf = var.ssm_param_arn_config_users_conf
  ssm_param_arn_fsx_domain        = var.ssm_param_arn_fsx_domain
  ssm_param_arn_fsx_username      = var.ssm_param_arn_fsx_username
  ssm_param_arn_fsx_password      = var.ssm_param_arn_fsx_password
  ssm_param_arn_fsx_users         = var.ssm_param_arn_fsx_users
}