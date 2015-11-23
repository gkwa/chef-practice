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
  root_block_device {
    volume_size = "100"
  }
  tags {
    Name = "cheftest"
  }
}














# this looks really good, but cname doesn't resolve:
#
# resource "aws_route53_zone" "streambox-com" {
#     name = "streambox.com"
# #     lifecycle {
# #         prevent_destroy = true
# #     }
# }
#
# resource "aws_route53_record" "streambox-com_a" {
#     zone_id = "${aws_route53_zone.streambox-com.zone_id}"
#     name = "streambox.com"
#     type = "A"
#     ttl = "300"
#     records = ["50.18.251.59"]
# }
#
# resource "aws_route53_record" "streambox-com_cname_chef" {
#     zone_id = "${aws_route53_zone.streambox-com.zone_id}"
#     name = "chef"
#     type = "CNAME"
#     ttl = "300"
#    records = ["${aws_instance.chef.public_dns}"]
# #    records = ["chef.streambox.com"]
# }
#
#
#
#








# 
# 
# resource "aws_route53_record" "chef_dns" {
#    zone_id = "streambox.com"
#    name = "chef.streambox.com"
#    type = "A"
#    ttl = "300"
# #   records = ["${aws_instance.public_ip}"]
#    records = ["127.0.0.1"]
# }
# 
# 


# 
# resource "aws_route53_zone" "chef" {
#   name = "chef.streambox.com"
# }
# 
# resource "aws_route53_record" "chef" {
#   zone_id = "${aws_route53_zone.chef.zone_id}"
#   name = "chef.chef.streambox.com"
#   type = "CNAME"
#   ttl = "300"
#   records = ["${aws_instance.chef.public_dns}"]
# }
# 
# 
# 




# CNAME with DNS name chef.streambox.com. is not permitted at apex in zone chef.streambox.com.
# CNAME with DNS name . is not permitted at apex in zone 
# 
# resource "aws_route53_zone" "primary" {
#   name = "streambox.com"
# }
# 
# # resource "aws_route53_record" "root" {
# #     zone_id = "${aws_route53_zone.primary.zone_id}"
# #     name = "streambox.com"
# #     type = "A"
# #     ttl = "300"
# #   records = ["${aws_instance.chef.public_ip}"]
# # }
# 
# # 
# # # terraform cname
# # 
# resource "aws_route53_record" "chef" {
#    zone_id = "streambox.com"
#    name = "chef.streambox.com"
#    type = "CNAME"
#    ttl = "300"
#    records = ["${aws_instance.chef.public_dns}"]
# }
# 
# # 
# 
# 
# resource "aws_route53_zone" "streambox" {
#   name = "streambox.com"
# }
# 
# resource "aws_route53_record" "chef" {
#   zone_id = "${aws_route53_zone.streambox.zone_id}"
#   domain
#   name = ".streambox.com"
#   type = "CNAME"
#   ttl = "300"
#   records = ["${aws_instance.streambox.ipv4_address}"]
# }
#
