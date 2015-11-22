provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_security_group" "cheftest" {
  name = "cheftest"
  description = "Allow ssh inbound traffic from everywhere"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
	Name = "cheftest"
  }
}

resource "aws_instance" "chef" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t1.micro"
  key_name = "ephemeral-test"
  volume_size = 100
  security_groups = ["${aws_security_group.cheftest.name}"]

  tags {
    Name = "cheftest"
  }
}
