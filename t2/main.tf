provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_security_group" "chef" {
  name = "chef"
  description = "Allow ssh inbound traffic from everywhere"

  ingress {
	from_port = 22
	to_port = 22
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
	Name = "chef"
  }
}

resource "aws_instance" "chef" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t1.micro"
  key_name = "ephemeral-test"
  security_groups = ["${aws_security_group.chef.name}"]
  root_block_device {
	volume_size = "100"
  }
  tags {
	Name = "chef"
  }
}

resource "aws_route53_record" "chef" {
  zone_id = "${var.streambox_zone}"
  ttl = "60"
  name = "chef.streambox.com"
  type = "A"
  records = ["${aws_instance.chef.public_ip}"]
}
