resource "aws_ssm_parameter" "sftp_config_users_conf" {
  name      = "${var.sftp_ssm_param_prefix}${var.sftp_ssm_param_config_users_conf}"
  type      = "SecureString"
  overwrite = true

  value = base64encode(templatefile("${path.module}/tpl/users.conf.tftpl", {
    sftp_users     = local.sftp_users
    sftp_uid_start = var.sftp_uid_start
  }))

}
