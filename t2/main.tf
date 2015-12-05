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
  monitoring = true
  root_block_device {
	volume_size = "100"
  }
  tags {
	Name = "chef"
  }

  provisioner "remote-exec" {
	inline = [

	  /* Clean, update machine */
	  "sudo rm /var/lib/apt/lists/* -vf",
	  "sudo apt-get clean",
	  "sudo apt-get autoremove",
	  "sudo apt-get -qq update",

	  "sudo apt-get -qq install --assume-yes git",

	  /* Install Chef server and packages */
	  "cd /tmp",
	  "curl -Lo chef-server-core_12.3.1-1_amd64.deb https://packagecloud.io/chef/stable/packages/ubuntu/precise/chef-server-core_12.3.1-1_amd64.deb/download",
	  "sudo dpkg -i chef-server-core_12.3.1-1_amd64.deb",
	  "sudo chef-server-ctl reconfigure",

	  /* Chef Manage */
	  "sudo chef-server-ctl install opscode-manage",
	  "sudo chef-server-ctl reconfigure",
	  "sudo opscode-manage-ctl reconfigure",

	  /* Chef Push Jobs */
	  "sudo chef-server-ctl install opscode-push-jobs-server",
	  "sudo chef-server-ctl reconfigure",
	  "sudo opscode-push-jobs-server-ctl reconfigure",

	  /* Chef replication */
	  "sudo chef-server-ctl install chef-sync",
	  "sudo chef-server-ctl reconfigure",
	  "sudo chef-sync-ctl reconfigure",

	  /* Reporting */
	  "sudo chef-server-ctl install opscode-reporting",
	  "sudo chef-server-ctl reconfigure",
	  "sudo opscode-reporting-ctl reconfigure"
	]
	connection {
      user = "ubuntu"
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
  value = "ssh -i ~/.ssh/ephemeral-test.pem ubuntu@${aws_instance.chef.public_ip}"
}
output "sshdns" {
  value = "ssh -i ~/.ssh/ephemeral-test.pem ubuntu@${aws_route53_record.chef.name}"
}
