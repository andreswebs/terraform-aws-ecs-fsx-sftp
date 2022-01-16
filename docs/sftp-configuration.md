
# SFTP configuration

The SFTP server configurations and SSH keys are injected from AWS SSM Parameter Store. Keys must be  
created externally for SFTP users and for the SFTP host, encoded as base64 values and stored in SSM parameters.

The SSM parameters must be created separately, with the correct values.

The parameter names are used as input for the Terraform configurations, through TF vars (see `variables.tf`).

Parameter names are built from TF vars in the form:
`<prefix><suffix>[<sftp user>]`

Prefix and suffix values must start with `/` and must not end with `/`. The prefix can be set to an empty string.

The prefix is given by the `sftp_ssm_param_prefix` TF var (default: `/sftp`).

The suffixes are:

- `sftp_ssm_param_user_pub_key`: precedes user public keys, one key per user (e.g., the final parameter name with prefix will be `/sftp/user/public-key/machine-user`)
- `sftp_ssm_param_host_pub_key`: host public key (default param name with prefix: `/sftp/host/public-key`)
- `sftp_ssm_param_host_priv_key`: host private key (default param name with prefix: `/sftp/host/private-key`)
 
The sftp container will also mount the `/etc/sftp/users.conf` file from an SSM parameter 
(default: `/sftp/config/users-conf`), given by the suffix `sftp_ssm_param_config_users_conf`. 
 
The 'users-conf' parameter is created from the template file: `tpl/users.conf.tftpl`
 