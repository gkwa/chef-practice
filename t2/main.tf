provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_route53_record" "chef" {
  zone_id = "${var.streambox_zone}"
  ttl = "60"
  name = "chef.streambox.com"
  type = "A"
  records = ["${aws_instance.chef.public_ip}"]
}

resource "aws_instance" "chef" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "m3.medium"
  key_name = "ephemeral-test"
  security_groups = ["${aws_security_group.chef.name}"]
  monitoring = true
  root_block_device {
	volume_size = "100"
  }

  tags {
	Name = "chef"
  }

  connection {
	agent = false
	user = "ubuntu"
	key_file = "~/.ssh/ephemeral-test.pem"
  }

  provisioner "file" {
	source = "script.sh"
	destination = "/tmp/script.sh"
  }

  provisioner "file" {
	source = "sethosts.sh"
	destination = "/tmp/sethosts.sh"
  }

  provisioner "file" {
	source = "sethostname.sh"
	destination = "/tmp/sethostname.sh"
  }

  provisioner "file" {
	source = "installemacs.sh"
	destination = "/tmp/installemacs.sh"
  }

  provisioner "file" {
	source = "s1.sh"
	destination = "/tmp/s1.sh"
  }

  provisioner "remote-exec" {
	inline = [
	  "sudo cp -R /home/ubuntu/.ssh /root" # enables ssh root@chef
	  ,"sudo sh /tmp/sethostname.sh"
	  ,"sudo sh /tmp/sethosts.sh"
	  ,"sudo service hostname restart"
	  ,"sudo nohup sh -x /tmp/s1.sh &"
	  ,"sleep 3" # without this, the nohup doesn't always run (not sure why)
	]
  }
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
  ingress {
	from_port = 443
	to_port = 443
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
	Name = "chef"
  }
}


output "sship" {
  value = "ssh -i ~/.ssh/ephemeral-test.pem ubuntu@${aws_instance.chef.public_ip}"
}
output "sshdns" {
  value = "ssh -i ~/.ssh/ephemeral-test.pem ubuntu@${aws_route53_record.chef.name}"
}
