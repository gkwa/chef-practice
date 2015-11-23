<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Summary for how to get started with terraform](#summary-for-how-to-get-started-with-terraform)
  - [Command summary](#command-summary)
  - [quickly check whether dns record was added](#quickly-check-whether-dns-record-was-added)
  - [provisioning failing on sudo password request](#provisioning-failing-on-sudo-password-request)
- [Terraform provisioning](#terraform-provisioning)
- [Install chef server](#install-chef-server)
- [TODO find aws ec2 command to find relevent t1.micro images for all regions](#todo-find-aws-ec2-command-to-find-relevent-t1micro-images-for-all-regions)
- [TODO find a way to automate the key generation, now I'm hard coding it](#todo-find-a-way-to-automate-the-key-generation-now-im-hard-coding-it)
- [Chef server getting started](#chef-server-getting-started)
- [Using ID in security group reference fails, but reference by name works](#using-id-in-security-group-reference-fails-but-reference-by-name-works)
  - [log](#log)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Summary for how to get started with terraform
=============================================

-   you need to create secrets.tfvars since its not version conrolled
-   determine the region you're going to work in
-   create new key. Here's url for us-west-2 region:
    <https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#KeyPairs:sort=keyName>
-   replace `key_name ` "ephemeral-test"= with your key name
-   run terraform

<!-- -->

    terraform destroy -force -var-file=secrets.tfvars
    time terraform apply -var-file=secrets.tfvars

-   continue here manually

<https://docs.chef.io/release/server_12-2/install_server.html#standalone>

    sudo chef-server-ctl reconfigure
    sudo chef-server-ctl user-create mtm taylor monacelli taylor.monacelli@streambox.com password --filename FILE_NAME"

Command summary
---------------

    terraform plan -var-file=secrets.tfvars
    terraform apply -var-file=secrets.tfvars
    terraform destroy -var-file=secrets.tfvars

quickly check whether dns record was added
------------------------------------------

We have multiple zones with same name, so use zone id instead of name.

    /Users/demo/Downloads/cli53-mac-amd64 export -f ZYM2WVE2N8MU5 | wc -l

provisioning failing on sudo password request
---------------------------------------------

<https://github.com/hashicorp/terraform/issues/492#issuecomment-59984941>
<https://terraform.io/docs/provisioners/connection.html>

\*\*

aws~instance~.chef (local-exec): Enter proxy password for user 'vh':
aws~instance~.chef (local-exec): Enter proxy password for user 'vh':
terraform Enter proxy password for user 'vh':

terraform local-exec curl

aws~instance~.chef: Provisioning with 'local-exec'... aws~instance~.chef
(local-exec): Executing: /bin/sh -c "cd /tmp && curl -O
<https://raw.githubusercontent.com/TaylorMonacelli/chef-practice/master/t2/chef_install.sh>
&& sh -x chef~install~.sh" aws~instance~.chef (local-exec): % Total %
Received % Xferd Average Speed Time Time Time Current aws~instance~.chef
(local-exec): Dload Upload Total Spent Left Speed aws~instance~.chef
(local-exec): 0 0 0 0 0 0 0 0 --:--:-- --:--:-- --:--:-- 0
aws~instance~.chef (local-exec): 0 0 0 0 0 0 0 0 --:--:-- --:--:--
--:--:-- 0 aws~instance~.chef (local-exec): 100 166 100 166 0 0 193 0
--:--:-- --:--:-- --:--:-- 193 aws~instance~.chef (local-exec): + cd
/tmp aws~instance~.chef (local-exec): + curl -O rpm -Uvh
<http://taylors-bucket.s3.amazonaws.com/chef-server-core-12.3.0-1.el5.x86_64.rpm>
aws~instance~.chef (local-exec): Enter proxy password for user 'vh':

Terraform provisioning
======================

<https://terraform.io/intro/getting-started/provision.html>

curl -o chef~install~.sh
<https://github.com/TaylorMonacelli/chef-practice/chef_install.sh>

Install chef server
===================

sudo -Hi wget
<http://taylors-bucket.s3.amazonaws.com/chef-server-core-12.3.0-1.el5.x86_64.rpm>
rpm -Uvh chef-server-core-12.3.0-1.el5.x86~64~.rpm

TODO find aws ec2 command to find relevent t1.micro images for all regions
==========================================================================

TODO find a way to automate the key generation, now I'm hard coding it
======================================================================

I generated this key using amazon webui: key~name~ = "ephemeral-test"

Can we doit thgouh terraform or other?

resource "aws~instance~" "chef" { ami = "\${lookup(var.amis,
var.region)}" instance~type~ = "t1.micro" key~name~ = "ephemeral-test"
security~groups~ = \["\${aws~securitygroup~.chef.name}"\]
root~blockdevice~ { volume~size~ = "100" } tags { Name = "chef" } }

Chef server getting started
===========================

\*\*

<http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html>

aws ec2 describe-images --owners amazon

\*\*

<https://docs.chef.io/release/server_12-2/install_server.html#standalone>
<http://downloads.chef.io/chef-server/>

Using ID in security group reference fails, but reference by name works
=======================================================================

<https://github.com/hashicorp/terraform/issues/575#issuecomment-64311829>

This fails: security~groups~ = \["\${aws~securitygroup~.cheftest.id}"\]

but this is ok: security~groups~ =
\["\${aws~securitygroup~.cheftest.name}"\]

log
---

\[demo@demos-MacBook-Pro:\~/pdev/chef-practice/t2(master)\]\$ g dc
--reverse main.tf diff --git a/t2/main.tf b/t2/main.tf index
1e9044e..bc6c161 100644 --- a/t2/main.tf ~~+~~ b/t2/main.tf @@ -24,7
+24,7 @@ resource "aws~instance~" "chef" { ami = "\${lookup(var.amis,
var.region)}" instance~type~ = "t1.micro" key~name~ = "ephemeral-test"
-   security~groups~ = \["\${aws~securitygroup~.cheftest.name}"\]
-   security~groups~ = \["\${aws~securitygroup~.cheftest.id}"\]

    tags { Name = "cheftest"

\[demo@demos-MacBook-Pro:\~/pdev/chef-practice/t2(master)\]\$ \#
