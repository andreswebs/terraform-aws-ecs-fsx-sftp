locals {

  ssm_param_arn_prefix = "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter"

  sftp_ssm_param_user_pub_key  = "${var.sftp_ssm_param_prefix}${var.sftp_ssm_param_user_pub_key}"
  sftp_ssm_param_host_pub_key  = "${var.sftp_ssm_param_prefix}${var.sftp_ssm_param_host_pub_key}"
  sftp_ssm_param_host_priv_key = "${var.sftp_ssm_param_prefix}${var.sftp_ssm_param_host_priv_key}"

  ssm_param_arn_user_pub_key  = "${local.ssm_param_arn_prefix}${local.sftp_ssm_param_user_pub_key}"
  ssm_param_arn_host_pub_key  = "${local.ssm_param_arn_prefix}${local.sftp_ssm_param_host_pub_key}"
  ssm_param_arn_host_priv_key = "${local.ssm_param_arn_prefix}${local.sftp_ssm_param_host_priv_key}"

  fsx_ssm_param_domain     = "${var.fsx_ssm_param_prefix}${var.fsx_ssm_param_domain}"
  fsx_ssm_param_username   = "${var.fsx_ssm_param_prefix}${var.fsx_ssm_param_username}"
  fsx_ssm_param_password   = "${var.fsx_ssm_param_prefix}${var.fsx_ssm_param_password}"
  fsx_ssm_param_ip_address = "${var.fsx_ssm_param_prefix}${var.fsx_ssm_param_ip_address}"

  ssm_param_arn_fsx_domain     = "${local.ssm_param_arn_prefix}${local.fsx_ssm_param_domain}"
  ssm_param_arn_fsx_username   = "${local.ssm_param_arn_prefix}${local.fsx_ssm_param_username}"
  ssm_param_arn_fsx_password   = "${local.ssm_param_arn_prefix}${local.fsx_ssm_param_password}"
  ssm_param_arn_fsx_ip_address = "${local.ssm_param_arn_prefix}${local.fsx_ssm_param_ip_address}"

}

resource "aws_ssm_parameter" "sftp_config_users_conf" {
  name      = "${var.sftp_ssm_param_prefix}${var.sftp_ssm_param_config_users_conf}"
  type      = "SecureString"
  overwrite = true

  value = base64encode(templatefile("${path.module}/tpl/users.conf.tftpl", {
    sftp_users     = local.sftp_users
    sftp_uid_start = var.sftp_uid_start
  }))

}
