
resource "aws_security_group" "internal" {
  vpc_id = var.vpc_id

  revoke_rules_on_delete = true

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  tags = {
    Name = format("ecs-%s-internal-sg", var.cluster_name)
  }

  name = format("ecs-%s-internal-sg", var.cluster_name)

}

resource "aws_security_group" "egress" {
  vpc_id = var.vpc_id

  revoke_rules_on_delete = true

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = format("ecs-%s-egress-sg", var.cluster_name)
  }

  name = format("ecs-%s-egress-sg", var.cluster_name)

}

resource "aws_security_group" "ssh" {
  vpc_id = var.vpc_id

  revoke_rules_on_delete = true

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cidr_whitelist
  }


  tags = {
    Name = format("ecs-%s-ssh-sg", var.cluster_name)
  }

  name = format("ecs-%s-ssh-sg", var.cluster_name)

}

resource "aws_security_group" "sftp" {
  vpc_id = var.vpc_id

  revoke_rules_on_delete = true

  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = var.cidr_whitelist
  }


  tags = {
    Name = format("ecs-%s-sftp-sg", var.cluster_name)
  }

  name = format("ecs-%s-sftp-sg", var.cluster_name)

}

