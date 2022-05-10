# terraform-aws-ecs-fsx-sftp

Deploys an AWS ECS cluster running an SFTP service as a daemon.

This is a proof-of-concept for how to deploy a highly-available fleet of SFTP servers with an AWS FSx Windows file share, with multiple user folders from the share mounted in ECS-optimized Amazon Linux 2 instances.

This module deploys a _subset_ of the resources described in the diagram below. Namely, it deploys the ECS cluster and SFTP daemon containers in the following architecture:

![Example SFTP service](https://raw.githubusercontent.com/andreswebs/terraform-aws-ecs-fsx-sftp/main/docs/img/ecs-fsx-sftp.svg)

## Pre-requisites

### FSx

The AWS FSx for Windows file system must be configured with access for a domain user with permissions to read and write to the file share. This user's credentials will be stored in plaintext in the ECS container instance.

An example module to deploy FSx with Active Directory can be found in the Terraform registry: [andreswebs/ad-fsx/aws](https://registry.terraform.io/modules/andreswebs/ad-fsx/aws/latest).

## Configuration

### FSx

FSx configuration values are injected into the ECS container instances via AWS SSM parameters. Parameters must be created separately with the correct values in the AWS account.

Refer to this [FSx documentation](https://github.com/andreswebs/terraform-aws-ecs-fsx-sftp/blob/main/docs/fsx-configuration.md) for how to pass the SSM parameter names into this module.

### SFTP

The SFTP server configuration and cryptographic keys injection is done via AWS SSM parameters. Parameters must be created separately with the correct SSH keys and configuration values in the AWS account. 

Refer to this [SFTP documentation](https://github.com/andreswebs/terraform-aws-ecs-fsx-sftp/blob/main/docs/sftp-configuration.md) for how to pass the SSM parameter names into this module.

The values in the example below will create 3 users with UIDs `1001`, `1002`, `1003`, respectively.

[//]: # (BEGIN_TF_DOCS)


## Usage

Example:

```hcl
module "sftp" {
  source         = "github.com/andreswebs/terraform-aws-ecs-fsx-sftp"
  cluster_name   = "example"
  vpc_id         = var.vpc_id
  subnet_ids     = var.subnet_ids
  cidr_whitelist = [var.corp_vpn]
  sftp_users     = "user-1,user-2,user-3"
  sftp_uid_start = 1001
}
```



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID for ECS container-instances | `string` | `null` | no |
| <a name="input_cidr_whitelist"></a> [cidr\_whitelist](#input\_cidr\_whitelist) | CIDR whitelist for allowed container-instance ingress traffic for SSH and SFTP | `list(string)` | `null` | no |
| <a name="input_cluster_desired_capacity"></a> [cluster\_desired\_capacity](#input\_cluster\_desired\_capacity) | ECS cluster ASG desired capacity | `number` | `2` | no |
| <a name="input_cluster_max_size"></a> [cluster\_max\_size](#input\_cluster\_max\_size) | ECS cluster ASG maximum instance count | `number` | `4` | no |
| <a name="input_cluster_min_size"></a> [cluster\_min\_size](#input\_cluster\_min\_size) | ECS cluster ASG minimum instance count | `number` | `1` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | ECS cluster name | `string` | `"sftp"` | no |
| <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn) | ECS 'Task Execution Role' ARN; overrides `execution_role_name` | `string` | `null` | no |
| <a name="input_execution_role_name"></a> [execution\_role\_name](#input\_execution\_role\_name) | ECS 'Task Execution Role' name; overriden by `execution_role_arn` | `string` | `"ecs-execution"` | no |
| <a name="input_fsx_cifs_max_buf_size"></a> [fsx\_cifs\_max\_buf\_size](#input\_fsx\_cifs\_max\_buf\_size) | CIFS maximum buffer size; find it with the command: `modinfo cifs | grep` | `string` | `"130048"` | no |
| <a name="input_fsx_creds_path"></a> [fsx\_creds\_path](#input\_fsx\_creds\_path) | FSx credentials filesystem path | `string` | `"/home/ec2-user/.fsx-credentials"` | no |
| <a name="input_fsx_file_share"></a> [fsx\_file\_share](#input\_fsx\_file\_share) | Name of the Windows file share to use | `string` | `"share"` | no |
| <a name="input_fsx_ip_address"></a> [fsx\_ip\_address](#input\_fsx\_ip\_address) | FSx IP address; set to the correct value | `string` | `"127.0.0.1"` | no |
| <a name="input_fsx_mount_point"></a> [fsx\_mount\_point](#input\_fsx\_mount\_point) | Filesystem path prefix for FSx shared stores; each SFTP user will have its own mount-point under this path, mapped to an FSx share path | `string` | `"/mnt/fsx"` | no |
| <a name="input_fsx_smb_version"></a> [fsx\_smb\_version](#input\_fsx\_smb\_version) | SMB protocol version; if in doubt, leave it as default | `string` | `"3.0"` | no |
| <a name="input_fsx_ssm_param_domain"></a> [fsx\_ssm\_param\_domain](#input\_fsx\_ssm\_param\_domain) | FSx domain SSM param path | `string` | `"/domain"` | no |
| <a name="input_fsx_ssm_param_ip_address"></a> [fsx\_ssm\_param\_ip\_address](#input\_fsx\_ssm\_param\_ip\_address) | FSx IP address SSM param path | `string` | `"/ip-address"` | no |
| <a name="input_fsx_ssm_param_password"></a> [fsx\_ssm\_param\_password](#input\_fsx\_ssm\_param\_password) | FSx password SSM param path | `string` | `"/password"` | no |
| <a name="input_fsx_ssm_param_prefix"></a> [fsx\_ssm\_param\_prefix](#input\_fsx\_ssm\_param\_prefix) | Prefix for SSM parameters used for FSx configuration | `string` | `"/fsx"` | no |
| <a name="input_fsx_ssm_param_username"></a> [fsx\_ssm\_param\_username](#input\_fsx\_ssm\_param\_username) | FSx username SSM param path | `string` | `"/username"` | no |
| <a name="input_instance_profile_name"></a> [instance\_profile\_name](#input\_instance\_profile\_name) | ECS container-instance IAM profile name; if `instance_role_arn` is set, this must be an existing instance profile associated to that IAM role | `string` | `"ecs-sftp-instance"` | no |
| <a name="input_instance_role_arn"></a> [instance\_role\_arn](#input\_instance\_role\_arn) | ECS container-instance IAM role ARN; overrides `instance_role_name` | `string` | `null` | no |
| <a name="input_instance_role_name"></a> [instance\_role\_name](#input\_instance\_role\_name) | ECS container-instance IAM role name; overriden by `instance_role_arn` | `string` | `"ecs-sftp-instance"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | ECS container-instance type | `string` | `"t3a.micro"` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | CloudWatch Logs retention in days | `number` | `30` | no |
| <a name="input_script_s3_bucket"></a> [script\_s3\_bucket](#input\_script\_s3\_bucket) | Name of an S3 bucket to store the FSx configuration script | `string` | n/a | yes |
| <a name="input_script_s3_key"></a> [script\_s3\_key](#input\_script\_s3\_key) | S3 object key for the FSx configuration script | `string` | `"fsx-config/configure-fsx.bash"` | no |
| <a name="input_sftp_config_container_image"></a> [sftp\_config\_container\_image](#input\_sftp\_config\_container\_image) | Config container image | `string` | `"bash:latest"` | no |
| <a name="input_sftp_host_port"></a> [sftp\_host\_port](#input\_sftp\_host\_port) | Host port for SFTP access | `number` | `2222` | no |
| <a name="input_sftp_main_container_image"></a> [sftp\_main\_container\_image](#input\_sftp\_main\_container\_image) | Main SFTP container image | `string` | `"atmoz/sftp:latest"` | no |
| <a name="input_sftp_ssm_param_config_users_conf"></a> [sftp\_ssm\_param\_config\_users\_conf](#input\_sftp\_ssm\_param\_config\_users\_conf) | SSM param path for the `/etc/sftp/users.conf` file | `string` | `"/config/users-conf"` | no |
| <a name="input_sftp_ssm_param_host_priv_key"></a> [sftp\_ssm\_param\_host\_priv\_key](#input\_sftp\_ssm\_param\_host\_priv\_key) | SSM param path for the host private key | `string` | `"/host/private-key"` | no |
| <a name="input_sftp_ssm_param_host_pub_key"></a> [sftp\_ssm\_param\_host\_pub\_key](#input\_sftp\_ssm\_param\_host\_pub\_key) | SSM param path for the host public key | `string` | `"/host/public-key"` | no |
| <a name="input_sftp_ssm_param_prefix"></a> [sftp\_ssm\_param\_prefix](#input\_sftp\_ssm\_param\_prefix) | Prefix for SSM parameters used for SFTP configuration | `string` | `"/sftp"` | no |
| <a name="input_sftp_ssm_param_user_pub_key"></a> [sftp\_ssm\_param\_user\_pub\_key](#input\_sftp\_ssm\_param\_user\_pub\_key) | SSM param path for users' public keys | `string` | `"/user/public-key"` | no |
| <a name="input_sftp_task_port"></a> [sftp\_task\_port](#input\_sftp\_task\_port) | ECS task port for SFTP access | `number` | `22` | no |
| <a name="input_sftp_uid_start"></a> [sftp\_uid\_start](#input\_sftp\_uid\_start) | Starting Unix UID for SFTP users; will be incremented by 1 for each extra user | `number` | `1001` | no |
| <a name="input_sftp_users"></a> [sftp\_users](#input\_sftp\_users) | Comma-separated list of SFTP users to add | `string` | n/a | yes |
| <a name="input_sftp_volume_name_config"></a> [sftp\_volume\_name\_config](#input\_sftp\_volume\_name\_config) | SFTP config-volume name | `string` | `"sftp-config"` | no |
| <a name="input_sftp_volume_name_host"></a> [sftp\_volume\_name\_host](#input\_sftp\_volume\_name\_host) | SFTP host-volume name | `string` | `"sftp-host"` | no |
| <a name="input_sftp_volume_name_scripts"></a> [sftp\_volume\_name\_scripts](#input\_sftp\_volume\_name\_scripts) | SFTP scripts-volume name | `string` | `"sftp-scripts"` | no |
| <a name="input_sftp_volume_name_storage"></a> [sftp\_volume\_name\_storage](#input\_sftp\_volume\_name\_storage) | SFTP storage-volumes name prefix; user names will be added as suffixes | `string` | `"sftp-storage"` | no |
| <a name="input_sftp_volume_name_user"></a> [sftp\_volume\_name\_user](#input\_sftp\_volume\_name\_user) | SFTP user-volumes name prefix; user names will be added as suffixes | `string` | `"sftp-user"` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | ECS container-instance SSH key-pair name; must be an existing key-pair | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs | `list(string)` | n/a | yes |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | (Optional) ARNs of target groups to associate the main container | `list(string)` | `[]` | no |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | ECS 'Task Role' ARN; overrides `task_role_name` | `string` | `null` | no |
| <a name="input_task_role_name"></a> [task\_role\_name](#input\_task\_role\_name) | ECS 'Task Role' name; overriden by `task_role_arn` | `string` | `"ecs-task"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam"></a> [iam](#module\_iam) | ./modules/iam | n/a |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster"></a> [ecs\_cluster](#output\_ecs\_cluster) | The aws\_ecs\_cluster resource |
| <a name="output_launch_template"></a> [launch\_template](#output\_launch\_template) | The aws\_launch\_template resource |
| <a name="output_task_definition"></a> [task\_definition](#output\_task\_definition) | The aws\_ecs\_task\_definition resource |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.12 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.12 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_capacity_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_s3_object.script_configure_fsx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_security_group.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.sftp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_parameter.sftp_config_users_conf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ami.ecs_ami_latest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_s3_bucket.script](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

[//]: # (END_TF_DOCS)

## Authors

**Andre Silva** - [@andreswebs](https://github.com/andreswebs)

## License

This project is licensed under the [Unlicense](UNLICENSE.md).

## Acknowledgements

This project is based on the public [docker.io/atmoz/sftp](https://hub.docker.com/r/atmoz/sftp) image.
