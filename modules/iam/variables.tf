variable "task_role_name" {
  type        = string
  default     = "ecs-sftp-task"
  description = "ECS 'Task Role' name"
}

variable "execution_role_name" {
  type        = string
  default     = "ecs-sftp-execution"
  description = "ECS 'Task Execution Role' name"
}

variable "instance_role_name" {
  type        = string
  default     = "ecs-sftp-instance"
  description = "ECS container instance role name"
}

variable "instance_profile_name" {
  type        = string
  default     = "ecs-sftp-instance"
  description = "ECS container instance profile name"
}

variable "ssm_param_arn_user_pub_key" {
  type        = string
  description = "SSM parameter ARN for users' public keys"
}

variable "ssm_param_arn_host_pub_key" {
  type        = string
  description = "SSM parameter ARN for host public key"
}

variable "ssm_param_arn_host_priv_key" {
  type        = string
  description = "SSM parameter ARN for host private key"
}

variable "ssm_param_arn_config_users_conf" {
  type        = string
  description = "SSM parameter ARN for the `/etc/sftp/users.conf` file"
}

variable "ssm_param_arn_fsx_domain" {
  type        = string
  description = "SSM parameter ARN for FSx Active Directory domain"
}

variable "ssm_param_arn_fsx_username" {
  type        = string
  description = "SSM parameter ARN for an AD user with write access to the FSX Windows file system"
}

variable "ssm_param_arn_fsx_password" {
  type        = string
  description = "SSM parameter ARN for the FSx AD user"
}

variable "ssm_param_arn_fsx_ip_address" {
  type        = string
  description = "SSM parameter ARN for the FSx IP address"
}

variable "create_execution_role" {
  type        = bool
  default     = true
  description = "Create Task Execution Role?"
}

variable "create_task_role" {
  type        = bool
  default     = true
  description = "Create Task Role?"
}

variable "create_instance_role" {
  type        = bool
  default     = true
  description = "Create instance role?"
}

variable "script_s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket storing the FSx configuration script"
}

variable "script_s3_key" {
  type        = string
  description = "S3 object key for the FSx configuration script"
  default     = "fsx-config/configure-fsx.bash"
}
