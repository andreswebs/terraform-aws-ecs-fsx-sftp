# FSx configuration

The FSx configuration is injected from AWS SSM Parameter Store.

The parameter names are used as input for the Terraform configurations, through
TF vars (see `variables.tf`).

Parameter names are built from TF vars in the form: `<prefix><suffix>`

Prefix and suffix values must start with `/` and must not end with `/`. The
prefix can be set to an empty string.

The prefix is given by the `fsx_ssm_param_prefix` TF var (default: `/fsx`).

The suffixes are:

- `fsx_ssm_param_domain`: AD domain name used by FSx (default param name with
  prefix: `/fsx/domain`)
- `fsx_ssm_param_username`: AD user name used by ECS container instances to
  mount FSx shares (default param name with prefix: `/fsx/username`)
- `fsx_ssm_param_password`: AD user password used by ECS container instances to
  mount FSx (default param name with prefix: `/fsx/password`)
- `fsx_ssm_param_ip_address`: FSx Windows file system 'preferred server IP address' (default param name with prefix:
  `/fsx/ip-address`)
