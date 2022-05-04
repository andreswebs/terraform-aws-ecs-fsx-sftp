locals {

  install_awscli = templatefile("${path.module}/tpl/install-awscli.tftpl", {})

  shell_functions = templatefile("${path.module}/tpl/functions.tftpl", {})

  fsx_config_command = templatefile("${path.module}/tpl/fsx-config.cmd.tftpl", {
    fsx_mount_point = var.fsx_mount_point
    sftp_uid_start  = var.sftp_uid_start
    sftp_users      = local.sftp_users
  })

  fsx_get_creds_command = templatefile("${path.module}/tpl/fsx-get-creds.cmd.tftpl", {
    fsx_creds_path         = var.fsx_creds_path
    fsx_ssm_param_domain   = local.fsx_ssm_param_domain
    fsx_ssm_param_username = local.fsx_ssm_param_username
    fsx_ssm_param_password = local.fsx_ssm_param_password
  })

  fsx_mount_command = templatefile("${path.module}/tpl/fsx-mount.cmd.tftpl", {
    sftp_uid_start           = var.sftp_uid_start
    sftp_users               = local.sftp_users
    fsx_ssm_param_ip_address = local.fsx_ssm_param_ip_address
    fsx_file_share           = var.fsx_file_share
    fsx_mount_point          = var.fsx_mount_point
    fsx_smb_version          = var.fsx_smb_version
    fsx_cifs_max_buf_size    = var.fsx_cifs_max_buf_size
    fsx_creds_path           = var.fsx_creds_path
  })

  fsx_config_script = templatefile("${path.module}/tpl/fsx-config.bash.tftpl", {
    install_awscli        = local.install_awscli
    shell_functions       = local.shell_functions
    fsx_config_command    = local.fsx_config_command
    fsx_get_creds_command = local.fsx_get_creds_command
    fsx_mount_command     = local.fsx_mount_command
  })

  run_fsx_config = templatefile("${path.module}/tpl/run-fsx-config.tftpl", {
    script_s3_bucket  = data.aws_s3_bucket.script.id
    script_s3_key     = var.script_s3_key
    script_file_local = "/usr/local/bin/configure-fsx"
  })

  user_data = base64encode(templatefile("${path.module}/tpl/userdata.tftpl", {
    cluster_name   = var.cluster_name
    install_awscli = local.install_awscli
    run_fsx_config = local.run_fsx_config
  }))

}

resource "aws_s3_object" "script_configure_fsx" {
  bucket  = data.aws_s3_bucket.script.id
  key     = var.script_s3_key
  content = local.fsx_config_script
}
