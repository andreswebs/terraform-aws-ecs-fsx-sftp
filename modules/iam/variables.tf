variable "task_role_name" {
  type        = string
  default     = "ecs-task"
  description = "ECS 'Task Role' name"
}

variable "execution_role_name" {
  type        = string
  default     = "ecs-execution"
  description = "ECS 'Task Execution Role' name"
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
