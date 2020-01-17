variable "AccessKeyID" {}

variable "SecretAccessKey" {}

variable "prefix" {
  default = "tf-aws-bigip"
}
## Different regions need other Jumphost and BigIP Instance Types
## Uncomment needed region below

variable "region" {
  # default = "eu-central-1"  # Europe (Frankfurt)
  default = "eu-north-1"    # Europe (Stockholm)
  # default = "us-west-2"     # US (Oregon)
}

variable "azs" {
  # default = ["eu-central-1a", "eu-central-1b"]  # Europe (Frankfurt)
  default = ["eu-north-1a", "eu-north-1b"]      # Europe (Stockholm)
  # default = ["us-west-2a", "us-west-2b"]        # US (Oregon)
}

variable "ec2_bigip_type" {
  # default = "c4.xlarge"   # Europe (Frankfurt)
  default = "c5.xlarge"   # Europe (Stockholm)
  # default = "c4.xlarge"   # US (Oregon)
}
variable "ec2_ubuntu_type" {
  # default = "t2.xlarge"   #Europe (Frankfurt)
  default = "t3.xlarge"   # Europe (Stockholm)
  # default = "t2.xlarge"   # US (Oregon)
}

variable "cidr" {
  default = "10.0.0.0/16"
}

variable "allowed_mgmt_cidr" {
  default = "0.0.0.0/0"
}

variable "allowed_app_cidr" {
  default = "0.0.0.0/0"
}

variable "management_subnet_offset" {
  default = 10
}

variable "external_subnet_offset" {
  default = 0
}

variable "internal_subnet_offset" {
  default = 20
}

variable "ec2_key_name" {
}

variable "ec2_key_file" {
}
