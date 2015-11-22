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
  security_groups = ["${aws_security_group.cheftest.name}"]

  tags {
    Name = "cheftest"
  }
}

resource "aws_ebs_volume" "chef" {
  availability_zone = "us-west-2a"
  size = 100
  tags {
    Name = "cheftest"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id = "${aws_ebs_volume.chef.id}"
  instance_id = "${aws_instance.chef.id}"
}
