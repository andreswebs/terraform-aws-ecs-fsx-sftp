variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs"
}

variable "cluster_name" {
  type        = string
  default     = "sftp"
  description = "ECS cluster name"
}

variable "cluster_desired_capacity" {
  type        = number
  default     = 2
  description = "ECS cluster ASG desired capacity"
}

variable "cluster_max_size" {
  type        = number
  default     = 4
  description = "ECS cluster ASG maximum instance count"
}

variable "cluster_min_size" {
  type        = number
  default     = 1
  description = "ECS cluster ASG minimum instance count"
}

variable "instance_type" {
  type        = string
  default     = "t3a.micro"
  description = "ECS container-instance type"
}

variable "ami_id" {
  type        = string
  default     = null
  description = "AMI ID for ECS container-instances"
}

variable "ssh_key_name" {
  type        = string
  default     = null
  description = "ECS container-instance SSH key-pair name; must be an existing key-pair"
}

variable "log_retention_in_days" {
  type        = number
  default     = 30
  description = "CloudWatch Logs retention in days"
}

variable "instance_role_arn" {
  type        = string
  default     = null
  description = "ECS container-instance IAM role ARN; overrides `instance_role_name`"
}

variable "execution_role_arn" {
  type        = string
  default     = null
  description = "ECS 'Task Execution Role' ARN; overrides `execution_role_name`"
}

variable "task_role_arn" {
  type        = string
  default     = null
  description = "ECS 'Task Role' ARN; overrides `task_role_name`"
}

variable "instance_role_name" {
  type        = string
  default     = "ecs-sftp-instance"
  description = "ECS container-instance IAM role name; overriden by `instance_role_arn`"
}

variable "instance_profile_name" {
  type        = string
  default     = "ecs-sftp-instance"
  description = "ECS container-instance IAM profile name; if `instance_role_arn` is set, this must be an existing instance profile associated to that IAM role"
}

variable "task_role_name" {
  type        = string
  default     = "ecs-task"
  description = "ECS 'Task Role' name; overriden by `task_role_arn`"
}

variable "execution_role_name" {
  type        = string
  default     = "ecs-execution"
  description = "ECS 'Task Execution Role' name; overriden by `execution_role_arn`"
}

variable "cidr_whitelist" {
  type        = list(string)
  default     = null
  description = "CIDR whitelist for allowed container-instance ingress traffic for SSH and SFTP"
}

variable "sftp_host_port" {
  type        = number
  default     = 2222
  description = "Host port for SFTP access"
}

variable "sftp_task_port" {
  type        = number
  default     = 22
  description = "ECS task port for SFTP access"
}

/**
* SFTP configuration: see `docs/sftp-configuration.md`
*/
variable "sftp_ssm_param_prefix" {
  type        = string
  default     = "/sftp"
  description = "Prefix for SSM parameters used for SFTP configuration"
}

variable "sftp_ssm_param_user_pub_key" {
  type        = string
  default     = "/user/public-key"
  description = "SSM param path for users' public keys"
}

variable "sftp_ssm_param_host_pub_key" {
  type        = string
  default     = "/host/public-key"
  description = "SSM param path for the host public key"
}

variable "sftp_ssm_param_host_priv_key" {
  type        = string
  default     = "/host/private-key"
  description = "SSM param path for the host private key"
}

/**
* `.../config/users-conf` SSM parameter is created from `tpl/users.conf.tpl`
*/
variable "sftp_ssm_param_config_users_conf" {
  type        = string
  default     = "/config/users-conf"
  description = "SSM param path for the `/etc/sftp/users.conf` file"
}

variable "sftp_uid_start" {
  type        = number
  default     = 1001
  description = "Starting Unix UID for SFTP users; will be incremented by 1 for each extra user"
}

variable "sftp_users" {
  type        = string
  description = "Comma-separated list of SFTP users to add"
}

variable "sftp_volume_name_storage" {
  type        = string
  default     = "sftp-storage"
  description = "SFTP storage-volumes name prefix; user names will be added as suffixes"
}

variable "sftp_volume_name_user" {
  type        = string
  default     = "sftp-user"
  description = "SFTP user-volumes name prefix; user names will be added as suffixes"
}

variable "sftp_volume_name_host" {
  type        = string
  default     = "sftp-host"
  description = "SFTP host-volume name"
}

variable "sftp_volume_name_config" {
  type        = string
  default     = "sftp-config"
  description = "SFTP config-volume name"
}

variable "sftp_volume_name_scripts" {
  type        = string
  default     = "sftp-scripts"
  description = "SFTP scripts-volume name"
}

variable "sftp_main_container_image" {
  type        = string
  default     = "atmoz/sftp:latest"
  description = "Main SFTP container image"
}

variable "sftp_config_container_image" {
  type        = string
  default     = "bash:latest"
  description = "Config container image"
}

/**
* FSx
*/

variable "fsx_ssm_param_prefix" {
  type        = string
  default     = "/fsx"
  description = "Prefix for SSM parameters used for FSx configuration"
}

variable "fsx_ssm_param_domain" {
  type        = string
  default     = "/domain"
  description = "FSx domain SSM param path"
}

variable "fsx_ssm_param_username" {
  type        = string
  default     = "/username"
  description = "FSx username SSM param path"
}

variable "fsx_ssm_param_password" {
  type        = string
  default     = "/password"
  description = "FSx password SSM param path"
}

variable "fsx_ssm_param_ip_address" {
  type        = string
  default     = "/ip-address"
  description = "FSx IP address SSM param path"
}

variable "fsx_creds_path" {
  type        = string
  default     = "/home/ec2-user/.fsx-credentials"
  description = "FSx credentials filesystem path"
}

variable "fsx_ip_address" {
  type        = string
  default     = "127.0.0.1"
  description = "FSx IP address; set to the correct value"
}

variable "fsx_file_share" {
  type        = string
  default     = "share"
  description = "Name of the Windows file share to use"
}

variable "fsx_mount_point" {
  type        = string
  default     = "/mnt/fsx"
  description = "Filesystem path prefix for FSx shared stores; each SFTP user will have its own mount-point under this path, mapped to an FSx share path"
}

variable "fsx_smb_version" {
  type        = string
  default     = "3.0"
  description = "SMB protocol version; if in doubt, leave it as default"
}

variable "fsx_cifs_max_buf_size" {
  type        = string
  default     = "130048"
  description = "CIFS maximum buffer size; find it with the command: `modinfo cifs | grep`"
}

variable "script_s3_bucket" {
  type        = string
  description = "Name of an S3 bucket to store the FSx configuration script"
}

variable "script_s3_key" {
  type        = string
  description = "S3 object key for the FSx configuration script"
  default     = "fsx-config/configure-fsx.bash"
}

variable "target_group_arns" {
  type        = list(string)
  description = "(Optional) ARNs of target groups to associate the main container"
  default     = []
}
