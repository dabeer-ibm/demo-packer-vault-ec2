variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "instance_name" {
  type    = string
  default = "demo-vault-packer-tf"
}

variable "vault_aws_role" {
  description = "Vault AWS secrets engine role that mints dynamic IAM creds"
  type        = string
  default     = "demo-builder"
}

variable "vault_ssh_kv_path" {
  description = "KV v2 path holding the demo SSH keypair"
  type        = string
  default     = "kv/data/demo/ssh"
}

variable "hcp_packer_bucket" {
  type    = string
  default = "demo-ubuntu-base"
}

variable "hcp_packer_channel" {
  type    = string
  default = "production"
}
