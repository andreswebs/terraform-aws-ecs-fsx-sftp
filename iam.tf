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
  ssm_param_arn_fsx_ip_address    = local.ssm_param_arn_fsx_ip_address

}
