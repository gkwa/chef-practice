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
  instance_type = "m3.medium"
  key_name = "ephemeral-test"
  security_groups = ["${aws_security_group.chef.name}"]
  root_block_device {
	volume_size = "100"
  }
  tags {
	Name = "chef"
  }

  provisioner "remote-exec" {
	inline = [
	  "cd /tmp",
	  "curl --silent -o chef_server.rpm http://taylors-bucket.s3.amazonaws.com/chef-server-core-12.3.0-1.el5.x86_64.rpm",
	  "sudo rpm -Uh chef_server.rpm"
	]
	connection {
      user = "fedora"
      key_file = "~/.ssh/ephemeral-test.pem"
    }
  }
}

resource "aws_route53_record" "chef" {
  zone_id = "${var.streambox_zone}"
  ttl = "60"
  name = "chef.streambox.com"
  type = "A"
  records = ["${aws_instance.chef.public_ip}"]
}

output "sship" {
  value = "ssh -i ~/.ssh/ephemeral-test.pem fedora@${aws_instance.chef.public_ip}"
}
output "sshdns" {
  value = "ssh -i ~/.ssh/ephemeral-test.pem fedora@${aws_route53_record.chef.name}"
}
