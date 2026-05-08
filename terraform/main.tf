# =============================================================================
# Lookup: AMI ID published by HCP Packer on the named channel
# =============================================================================
data "hcp_packer_artifact" "ubuntu" {
  bucket_name  = var.hcp_packer_bucket
  channel_name = var.hcp_packer_channel
  platform     = "aws"
  region       = var.aws_region
}

# =============================================================================
# Lookup: SSH public key from Vault KV v2
# =============================================================================
data "vault_kv_secret_v2" "ssh" {
  mount = "kv"
  name  = "demo/ssh"
}

# =============================================================================
# Lookup: default VPC + default security group + first default subnet
#         (we do NOT create any networking resources)
# =============================================================================
data "aws_vpc" "default" {
  default = true
}

data "aws_ec2_instance_type_offerings" "supported" {
  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
  location_type = "availability-zone"
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
  filter {
    name   = "availability-zone"
    values = data.aws_ec2_instance_type_offerings.supported.locations
  }
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

# =============================================================================
# Import the SSH public key (from Vault) as an AWS key pair so EC2 can attach it
# =============================================================================
resource "aws_key_pair" "demo" {
  key_name   = "${var.instance_name}-key"
  public_key = data.vault_kv_secret_v2.ssh.data["public_key"]
}

# =============================================================================
# EC2 instance — default VPC, default SG, AMI from HCP Packer, key from Vault
# =============================================================================
resource "aws_instance" "demo" {
  ami           = data.hcp_packer_artifact.ubuntu.external_identifier
  instance_type = var.instance_type
  key_name      = aws_key_pair.demo.key_name

  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [data.aws_security_group.default.id]

  tags = {
    Name        = var.instance_name
    Source      = "hcp-packer"
    ManagedBy   = "terraform"
    Environment = "demo"
  }
}
