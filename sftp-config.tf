locals {

  sftp_main_container_name   = "sftp"
  sftp_config_container_name = "sftp-config"

  sftp_config_secrets = templatefile("${path.module}/tpl/sftp-config-secrets.json.tftpl", {
    ssm_param_arn_user_pub_key  = local.ssm_param_arn_user_pub_key
    ssm_param_arn_host_pub_key  = local.ssm_param_arn_host_pub_key
    ssm_param_arn_host_priv_key = local.ssm_param_arn_host_priv_key
    ssm_param_arn_users_conf    = aws_ssm_parameter.sftp_config_users_conf.arn
    sftp_users                  = var.sftp_users
  })

  sftp_config_command = templatefile("${path.module}/tpl/sftp-config-cmd.json.tftpl", {
    volume_name_user    = var.sftp_volume_name_user
    volume_name_host    = var.sftp_volume_name_host
    volume_name_config  = var.sftp_volume_name_config
    volume_name_scripts = var.sftp_volume_name_scripts
    sftp_users          = var.sftp_users
  })

  sftp_container_definitions = templatefile("${path.module}/tpl/sftp-container-definitions.json.tftpl", {
    aws_region             = data.aws_region.current.name
    log_group_name         = aws_cloudwatch_log_group.this.name
    main_container_name    = local.sftp_main_container_name
    main_container_image   = var.sftp_main_container_image
    config_container_name  = local.sftp_config_container_name
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
    sftp_users             = var.sftp_users
  })

}
