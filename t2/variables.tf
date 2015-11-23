variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "us-west-2"
}

variable "streambox_zone" {
  default = "ZYM2WVE2N8MU5"
}

variable "amis" {
  default = {
	us-west-2 = "ami-5189a661"
  }
}
