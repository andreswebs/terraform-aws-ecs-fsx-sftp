# terraform-aws-ecs-fsx-sftp iam

[//]: # (BEGIN_TF_DOCS)
Deploys IAM resources for terraform-aws-ecs-fsx-sftp.

## Usage

Example:

```hcl
module "iam" {
  source                          = "github.com/andreswebs/terraform-aws-ecs-fsx-sftp//modules/iam"
  task_role_name                  = var.task_role_name
  execution_role_name             = var.execution_role_name
  ssm_param_arn_user_pub_key      = var.ssm_param_arn_user_pub_key
  ssm_param_arn_host_pub_key      = var.ssm_param_arn_host_pub_key
  ssm_param_arn_host_priv_key     = var.ssm_param_arn_host_priv_key
  ssm_param_arn_config_users_conf = var.ssm_param_arn_config_users_conf
}
```



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_execution_role"></a> [create\_execution\_role](#input\_create\_execution\_role) | Create Task Execution Role? | `bool` | `true` | no |
| <a name="input_create_task_role"></a> [create\_task\_role](#input\_create\_task\_role) | Create Task Role? | `bool` | `true` | no |
| <a name="input_execution_role_name"></a> [execution\_role\_name](#input\_execution\_role\_name) | ECS 'Task Execution Role' name | `string` | `"ecs-execution"` | no |
| <a name="input_ssm_param_arn_config_users_conf"></a> [ssm\_param\_arn\_config\_users\_conf](#input\_ssm\_param\_arn\_config\_users\_conf) | SSM parameter ARN for the `/etc/sftp/users.conf` file | `string` | n/a | yes |
| <a name="input_ssm_param_arn_host_priv_key"></a> [ssm\_param\_arn\_host\_priv\_key](#input\_ssm\_param\_arn\_host\_priv\_key) | SSM parameter ARN for host private key | `string` | n/a | yes |
| <a name="input_ssm_param_arn_host_pub_key"></a> [ssm\_param\_arn\_host\_pub\_key](#input\_ssm\_param\_arn\_host\_pub\_key) | SSM parameter ARN for host public key | `string` | n/a | yes |
| <a name="input_ssm_param_arn_user_pub_key"></a> [ssm\_param\_arn\_user\_pub\_key](#input\_ssm\_param\_arn\_user\_pub\_key) | SSM parameter ARN for users' public keys | `string` | n/a | yes |
| <a name="input_task_role_name"></a> [task\_role\_name](#input\_task\_role\_name) | ECS 'Task Role' name | `string` | `"ecs-task"` | no |

## Modules

No modules.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role"></a> [role](#output\_role) | ECS roles |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.48.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.48.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_execution_permissions_sftp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_execution_role_sftp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.access_secrets_sftp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_execution_permissions_sftp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_tasks_trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm_messages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

[//]: # (END_TF_DOCS)
