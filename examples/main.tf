module "sftp" {
  source         = "github.com/andreswebs/terraform-aws-ecs-fsx-sftp"
  cluster_name   = "example"
  vpc_id         = var.vpc_id
  subnet_ids     = var.subnet_ids
  cidr_whitelist = [var.corp_vpn]
  sftp_users     = "user-1,user-2,user-3"
  sftp_uid_start = 1001
}