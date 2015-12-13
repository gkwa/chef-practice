<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Summary for how to get started with terraform](#summary-for-how-to-get-started-with-terraform)
  - [Command summary](#command-summary)
  - [quickly check whether dns record was added](#quickly-check-whether-dns-record-was-added)
  - [provisioning failing on sudo password request](#provisioning-failing-on-sudo-password-request)
- [Terraform provisioning](#terraform-provisioning)
  - [TODO try to get rid of running provisioning in terminal so I can go do other stuff](#todo-try-to-get-rid-of-running-provisioning-in-terminal-so-i-can-go-do-other-stuff)
  - [time required to provision on m3.medium: 14 minutes](#time-required-to-provision-on-m3medium-14-minutes)
- [Install chef server](#install-chef-server)
- [Oops: chef-server-ctl install opscode-manage fails](#oops-chef-server-ctl-install-opscode-manage-fails)
- [TODO local-exec versus remote-exec?](#todo-local-exec-versus-remote-exec)
- [TODO can we change the order of deployment steps?](#todo-can-we-change-the-order-of-deployment-steps)
- [TODO find aws ec2 command to find relevent t1.micro images for all regions](#todo-find-aws-ec2-command-to-find-relevent-t1micro-images-for-all-regions)
- [TODO find a way to automate the key generation, now I'm hard coding it](#todo-find-a-way-to-automate-the-key-generation-now-im-hard-coding-it)
- [Can remote-exec go in separate file?](#can-remote-exec-go-in-separate-file)
- [Note: You didn't specify an "-out" parameter to save this plan](#note-you-didnt-specify-an--out-parameter-to-save-this-plan)
- [Chef server getting started](#chef-server-getting-started)
- [Using ID in security group reference fails, but reference by name works](#using-id-in-security-group-reference-fails-but-reference-by-name-works)
  - [log](#log)
- [Troubleshooting](#troubleshooting)
  - [aws~instance~.chef (remote-exec): dpkg-deb: error: \`chef~server~.deb' is not a debian format archive](#awsinstancechef-remote-exec-dpkg-deb-error-%5Cchefserverdeb-is-not-a-debian-format-archive)
  - [DONE terraform can't force destroy, or how can I get terraform to destroy group first](#done-terraform-cant-force-destroy-or-how-can-i-get-terraform-to-destroy-group-first)
  - [ssh: handshake failed: ssh: unable to authenticate, attempted methods \[none publickey\], no supported methods remain](#ssh-handshake-failed-ssh-unable-to-authenticate-attempted-methods-%5Cnone-publickey%5C-no-supported-methods-remain)

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

    sudo chef-server-ctl reconfigure # done in main.tf
    sudo chef-server-ctl user-create mtm taylor monacelli taylor.monacelli@streambox.com password --filename mtm.pem
    sudo chef-server-ctl org-create streambox "Streambox Inc" --association_user mtm --filename streambox-validator.pem
    chef-server-ctl install opscode-manage

Command summary
---------------

    terraform plan -var-file=secrets.tfvars
    terraform apply -var-file=secrets.tfvars
    terraform destroy -var-file=secrets.tfvars

\*

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
<https://terraform.io/docs/provisioners>

curl -o chef~install~.sh
<https://github.com/TaylorMonacelli/chef-practice/chef_install.sh>

TODO try to get rid of running provisioning in terminal so I can go do other stuff
----------------------------------------------------------------------------------

Running 'local-exec'

``` {.hcl}
  provisioner "remote-exec" {
    inline = [
      "cd /tmp",
      "curl --silent -o chef_server.rpm http://taylors-bucket.s3.amazonaws.com/chef-server-core-12.3.0-1.el5.x86_64.rpm",
      "sudo rpm -Uh chef_server.rpm",
      "sudo chef-server-ctl reconfigure"
    ]
    connection {
      user = "fedora"
      key_file = "~/.ssh/ephemeral-test.pem"
    }
  }
```

time required to provision on m3.medium: 14 minutes
---------------------------------------------------

real 14m31.463s aws~instance~.chef (remote-exec): Chef Client finished,
417/482 resources updated in 07 minutes 52 seconds

aws~instance~.chef (remote-exec): Recipe: private-chef::nginx
aws~instance~.chef (remote-exec): \* execute\[restart~nginxlogservice~\]
action run

aws~instance~.chef (remote-exec): - execute /opt/opscode/embedded/bin/sv
restart /opt/opscode/sv/nginx/log aws~instance~.chef (remote-exec):
aws~instance~.chef (remote-exec): aws~instance~.chef (remote-exec):
Running handlers: aws~instance~.chef (remote-exec): Running handlers
complete

aws~instance~.chef (remote-exec): aws~instance~.chef (remote-exec):
Deprecated features used! aws~instance~.chef (remote-exec): Cannot
specify both default and name~property~ together on property path of
resource yum~globalconfig~. Only one (name~property~) will be obeyed. In
Chef 13, this will bec\$ aws~instance~.chef (remote-exec): -
/opt/opscode/embedded/cookbooks/cache/cookbooks/yum/resources/globalconfig.rb:76:in
\`class~fromfile~' aws~instance~.chef (remote-exec): aws~instance~.chef
(remote-exec): Chef Client finished, 417/482 resources updated in 07
minutes 52 seconds aws~instance~.chef (remote-exec): Chef Server
Reconfigured! aws~instance~.chef: Creation complete
aws~route53record~.chef: Modifying... records.1045054549:
"54.188.119.82" =&gt; "" records.2746339273: "" =&gt; "54.190.99.78"
aws~route53record~.chef: Modifications complete

Apply complete! Resources: 1 added, 1 changed, 1 destroyed.

The state of your infrastructure has been saved to the path below. This
state is required to modify and destroy your infrastructure, so keep it
safe. To inspect the complete state use the \`terraform show\` command.

State path: terraform.tfstate

Outputs:

sshdns = ssh -i \~/.ssh/ephemeral-test.pem fedora@chef.streambox.com
sship = ssh -i \~/.ssh/ephemeral-test.pem fedora@54.190.99.78

real 14m31.463s user 0m6.201s sys 0m3.856s
\[demo@demos-MBP:\~/pdev/chef-practice/t2(master)\]\$
\[demo@demos-MBP:\~/pdev/chef-practice/t2(master)\]\$
\[demo@demos-MBP:\~/.ssh(master)\]\$

Install chef server
===================

sudo -Hi wget
<http://taylors-bucket.s3.amazonaws.com/chef-server-core-12.3.0-1.el5.x86_64.rpm>
rpm -Uvh chef-server-core-12.3.0-1.el5.x86~64~.rpm

Oops: chef-server-ctl install opscode-manage fails
==================================================

Here's the list of supported platforms
<https://docs.chef.io/supported_platforms.html>

Try switching from fedora to centOS

chef-server-ctl install opscode-manage

<https://docs.chef.io/release/server_12-2/install_server.html#standalone>

    [root@ip-10-220-159-202 ~]# chef-server-ctl install opscode-manage
    Starting Chef Client, version 12.5.1
    resolving cookbooks for run list: ["private-chef::add_ons_wrapper"]
    Synchronizing Cookbooks:
      - chef-sugar (3.1.1)
      - apt (2.7.0)
      - yum (3.6.0)
      - runit (1.6.0)
      - enterprise (0.5.1)
      - openssl (4.4.0)
      - private-chef (0.1.0)
      - packagecloud (0.0.18)
    Compiling Cookbooks...

    ================================================================================
    Recipe Compile Error in /opt/opscode/embedded/cookbooks/cache/cookbooks/private-chef/recipes/add_ons_wrapper.rb
    ================================================================================

    RuntimeError
    ------------
    I don't know how to install addons for platform family: fedora

    Cookbook Trace:
    ---------------
      /opt/opscode/embedded/cookbooks/cache/cookbooks/private-chef/recipes/add_ons_repository.rb:47:in `from_file'
      /opt/opscode/embedded/cookbooks/cache/cookbooks/private-chef/recipes/add_ons_remote.rb:13:in `from_file'
      /opt/opscode/embedded/cookbooks/cache/cookbooks/private-chef/recipes/add_ons_wrapper.rb:47:in `from_file'

    Relevant File Content:
    ----------------------
    /opt/opscode/embedded/cookbooks/cache/cookbooks/private-chef/recipes/add_ons_repository.rb:

     40:      enabled false
     41:      action :create
     42:    end
     43:
     44:  else
     45:    # TODO: probably don't actually want to fail out?  Say, on any platform where
     46:    # this would have to be done manually.
     47>>   raise "I don't know how to install addons for platform family: #{node['platform_family']}"
     48:  end
     49:


    Running handlers:
      - #<Class:0x000000039a3e38>::AddonInstallHandler
    Running handlers complete
    Chef Client failed. 0 resources updated in 18 seconds
    [2015-11-23T06:15:12+00:00] FATAL: Stacktrace dumped to /opt/opscode/embedded/cookbooks/cache/chef-stacktrace.out
    [2015-11-23T06:15:12+00:00] FATAL: RuntimeError: I don't know how to install addons for platform family: fedora
    [root@ip-10-220-159-202 ~]#

TODO local-exec versus remote-exec?
===================================

Can we provision with sudo for local-exec as well as remote-exec?

terraform local-exec sudo

TODO can we change the order of deployment steps?
=================================================

I'd like remote-exec to run after machine has dns name. Can we change
order?

terraform remote-exec order change terraform remote-exec order

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

Can remote-exec go in separate file?
====================================

Yes, here's how
<https://terraform.io/docs/provisioners/remote-exec.html>

Note: You didn't specify an "-out" parameter to save this plan
==============================================================

<https://www.terraform.io/docs/commands/plan.html>

Maybe this: Note: You didn't specify an "-out" parameter to save this
plan "apply" is called, Terraform can't guarantee this is what will
execute.

is an alert that we can improve reliability.

terraform Note: You didn't specify an out parameter to save this plan
terraform Note: specify an "out parameter" to save this plan terraform
specify an out parameter to save this plan

\[demo@demos-MacBook-Pro:\~/pdev/chef-practice/t2(master)\]\$ terraform
plan -var-file=secrets.tfvars Refreshing Terraform state prior to
plan...

aws~instance~.chef: Refreshing state... (ID: i-ad3ef077)
aws~securitygroup~.chef: Refreshing state... (ID: sg-45fc4976)

The Terraform execution plan has been generated and is shown below.
Resources are shown in alphabetical order for quick scanning. Green
resources will be created (or destroyed and then created if an existing
resource exists), yellow resources are being changed in-place, and red
resources will be destroyed.

Note: You didn't specify an "-out" parameter to save this plan, so when
"apply" is called, Terraform can't guarantee this is what will execute.

-/+ aws~instance~.chef ami: "" =&gt; "ami-5189a661" availability~zone~:
"" =&gt; "&lt;computed&gt;" ebs~blockdevice~.\#: "" =&gt;
"&lt;computed&gt;" ephemeral~blockdevice~.\#: "" =&gt;
"&lt;computed&gt;" instance~type~: "" =&gt; "m3.medium" key~name~: ""
=&gt; "ephemeral-test" monitoring: "" =&gt; "1" placement~group~: ""
=&gt; "&lt;computed&gt;" private~dns~: "" =&gt; "&lt;computed&gt;"
private~ip~: "" =&gt; "&lt;computed&gt;" public~dns~: "" =&gt;
"&lt;computed&gt;" public~ip~: "" =&gt; "&lt;computed&gt;"
root~blockdevice~.\#: "" =&gt; "1"
root~blockdevice~.0.delete~ontermination~: "" =&gt; "1"
root~blockdevice~.0.iops: "" =&gt; "&lt;computed&gt;"
root~blockdevice~.0.volume~size~: "" =&gt; "100"
root~blockdevice~.0.volume~type~: "" =&gt; "&lt;computed&gt;"
security~groups~.\#: "" =&gt; "1" security~groups~.4064823014: "" =&gt;
"chef" source~destcheck~: "" =&gt; "1" subnet~id~: "" =&gt;
"&lt;computed&gt;" tags.\#: "" =&gt; "1" tags.Name: "" =&gt; "chef"
tenancy: "" =&gt; "&lt;computed&gt;" vpc~securitygroupids~.\#: "" =&gt;
"&lt;computed&gt;"

-   aws~route53record~.chef fqdn: "" =&gt; "&lt;computed&gt;" name: ""
    =&gt; "chef.streambox.com" records.\#: "" =&gt; "&lt;computed&gt;"
    ttl: "" =&gt; "60" type: "" =&gt; "A" zone~id~: "" =&gt;
    "ZYM2WVE2N8MU5"

Plan: 2 to add, 0 to change, 0 to destroy.
\[demo@demos-MacBook-Pro:\~/pdev/chef-practice/t2(master)\]\$

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

Troubleshooting
===============

aws~instance~.chef (remote-exec): dpkg-deb: error: \`chef~server~.deb' is not a debian format archive
-----------------------------------------------------------------------------------------------------

opscode-omnibus-packages chef server

curl --silent -o chef~server~.deb
<https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/14.04/x86_64/chef_12.5.1-1_amd64.deb>

chef server is not a debian format archive

aws~instance~.chef (remote-exec): dpkg-deb: error: \`chef~server~.deb'
is not a debian format archive

    [demo@demos-MBP:~/pdev/chef-practice/t2(master)]$ time terraform apply -var-file=secrets.tfvars
    aws_security_group.chef: Creating...
      description:                          "" => "Allow ssh inbound traffic from everywhere"
      egress.#:                             "" => "<computed>"
      ingress.#:                            "" => "1"
      ingress.2541437006.cidr_blocks.#:     "" => "1"
      ingress.2541437006.cidr_blocks.0:     "" => "0.0.0.0/0"
      ingress.2541437006.from_port:         "" => "22"
      ingress.2541437006.protocol:          "" => "tcp"
      ingress.2541437006.security_groups.#: "" => "0"
      ingress.2541437006.self:              "" => "0"
      ingress.2541437006.to_port:           "" => "22"
      name:                                 "" => "chef"
      owner_id:                             "" => "<computed>"
      tags.#:                               "" => "1"
      tags.Name:                            "" => "chef"
      vpc_id:                               "" => "<computed>"
    aws_security_group.chef: Creation complete
    aws_instance.chef: Creating...
      ami:                                       "" => "ami-5189a661"
      availability_zone:                         "" => "<computed>"
      ebs_block_device.#:                        "" => "<computed>"
      ephemeral_block_device.#:                  "" => "<computed>"
      instance_type:                             "" => "m3.medium"
      key_name:                                  "" => "ephemeral-test"
      monitoring:                                "" => "1"
      placement_group:                           "" => "<computed>"
      private_dns:                               "" => "<computed>"
      private_ip:                                "" => "<computed>"
      public_dns:                                "" => "<computed>"
      public_ip:                                 "" => "<computed>"
      root_block_device.#:                       "" => "1"
      root_block_device.0.delete_on_termination: "" => "1"
      root_block_device.0.iops:                  "" => "<computed>"
      root_block_device.0.volume_size:           "" => "100"
      root_block_device.0.volume_type:           "" => "<computed>"
      security_groups.#:                         "" => "1"
      security_groups.4064823014:                "" => "chef"
      source_dest_check:                         "" => "1"
      subnet_id:                                 "" => "<computed>"
      tags.#:                                    "" => "1"
      tags.Name:                                 "" => "chef"
      tenancy:                                   "" => "<computed>"
      vpc_security_group_ids.#:                  "" => "<computed>"
    aws_instance.chef: Provisioning with 'remote-exec'...
    aws_instance.chef (remote-exec): Connecting to remote host via SSH...
    aws_instance.chef (remote-exec):   Host: 54.218.172.233
    aws_instance.chef (remote-exec):   User: ubuntu
    aws_instance.chef (remote-exec):   Password: false
    aws_instance.chef (remote-exec):   Private key: true
    aws_instance.chef (remote-exec):   SSH Agent: true
    aws_instance.chef (remote-exec): Connecting to remote host via SSH...
    aws_instance.chef (remote-exec):   Host: 54.218.172.233
    aws_instance.chef (remote-exec):   User: ubuntu
    aws_instance.chef (remote-exec):   Password: false
    aws_instance.chef (remote-exec):   Private key: true
    aws_instance.chef (remote-exec):   SSH Agent: true
    aws_instance.chef (remote-exec): Connecting to remote host via SSH...
    aws_instance.chef (remote-exec):   Host: 54.218.172.233
    aws_instance.chef (remote-exec):   User: ubuntu
    aws_instance.chef (remote-exec):   Password: false
    aws_instance.chef (remote-exec):   Private key: true
    aws_instance.chef (remote-exec):   SSH Agent: true
    aws_instance.chef (remote-exec): Connecting to remote host via SSH...
    aws_instance.chef (remote-exec):   Host: 54.218.172.233
    aws_instance.chef (remote-exec):   User: ubuntu
    aws_instance.chef (remote-exec):   Password: false
    aws_instance.chef (remote-exec):   Private key: true
    aws_instance.chef (remote-exec):   SSH Agent: true
    aws_instance.chef (remote-exec): Connecting to remote host via SSH...
    aws_instance.chef (remote-exec):   Host: 54.218.172.233
    aws_instance.chef (remote-exec):   User: ubuntu
    aws_instance.chef (remote-exec):   Password: false
    aws_instance.chef (remote-exec):   Private key: true
    aws_instance.chef (remote-exec):   SSH Agent: true
    aws_instance.chef (remote-exec): Connected!
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/lock’
    aws_instance.chef (remote-exec): rm: cannot remove ‘/var/lib/apt/lists/partial’: Is a directory
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/security.ubuntu.com_ubuntu_dists_trusty-security_Release’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/security.ubuntu.com_ubuntu_dists_trusty-security_Release.gpg’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/security.ubuntu.com_ubuntu_dists_trusty-security_main_binary-amd64_Packages’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/security.ubuntu.com_ubuntu_dists_trusty-security_main_i18n_Translation-en’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/security.ubuntu.com_ubuntu_dists_trusty-security_multiverse_binary-amd64_Packages’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/security.ubuntu.com_ubuntu_dists_trusty-security_multiverse_i18n_Translation-en’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/security.ubuntu.com_ubuntu_dists_trusty-security_restricted_binary-amd64_Packages’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/security.ubuntu.com_ubuntu_dists_trusty-security_restricted_i18n_Translation-en’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/security.ubuntu.com_ubuntu_dists_trusty-security_universe_binary-amd64_Packages’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/security.ubuntu.com_ubuntu_dists_trusty-security_universe_i18n_Translation-en’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty-updates_Release’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty-updates_Release.gpg’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty-updates_main_binary-amd64_Packages’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty-updates_main_i18n_Translation-en’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty-updates_multiverse_binary-amd64_Packages’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty-updates_multiverse_i18n_Translation-en’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty-updates_restricted_binary-amd64_Packages’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty-updates_restricted_i18n_Translation-en’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty-updates_universe_binary-amd64_Packages’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty-updates_universe_i18n_Translation-en’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty_Release’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty_Release.gpg’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty_main_binary-amd64_Packages’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty_main_i18n_Translation-en’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty_multiverse_binary-amd64_Packages’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty_multiverse_i18n_Translation-en’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty_restricted_binary-amd64_Packages’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty_restricted_i18n_Translation-en’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty_universe_binary-amd64_Packages’
    aws_instance.chef (remote-exec): removed ‘/var/lib/apt/lists/us-west-2.ec2.archive.ubuntu.com_ubuntu_dists_trusty_universe_i18n_Translation-en’
    aws_instance.chef (remote-exec): Reading package lists... 0%
    aws_instance.chef (remote-exec): Reading package lists... 0%
    aws_instance.chef (remote-exec): Reading package lists... 22%
    aws_instance.chef (remote-exec): Reading package lists... Done
    aws_instance.chef (remote-exec): Building dependency tree... 0%
    aws_instance.chef (remote-exec): Building dependency tree... 0%
    aws_instance.chef (remote-exec): Building dependency tree... 50%
    aws_instance.chef (remote-exec): Building dependency tree... 50%
    aws_instance.chef (remote-exec): Building dependency tree
    aws_instance.chef (remote-exec): Reading state information... 0%
    aws_instance.chef (remote-exec): Reading state information... 8%
    aws_instance.chef (remote-exec): Reading state information... Done
    aws_instance.chef (remote-exec): 0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
    aws_instance.chef (remote-exec): Selecting previously unselected package liberror-perl.
    aws_instance.chef (remote-exec): (Reading database ...
    aws_instance.chef (remote-exec): (Reading database ... 5%
    aws_instance.chef (remote-exec): (Reading database ... 10%
    aws_instance.chef (remote-exec): (Reading database ... 15%
    aws_instance.chef (remote-exec): (Reading database ... 20%
    aws_instance.chef (remote-exec): (Reading database ... 25%
    aws_instance.chef (remote-exec): (Reading database ... 30%
    aws_instance.chef (remote-exec): (Reading database ... 35%
    aws_instance.chef (remote-exec): (Reading database ... 40%
    aws_instance.chef (remote-exec): (Reading database ... 45%
    aws_instance.chef (remote-exec): (Reading database ... 50%
    aws_instance.chef (remote-exec): (Reading database ... 55%
    aws_instance.chef (remote-exec): (Reading database ... 60%
    aws_instance.chef (remote-exec): (Reading database ... 65%
    aws_instance.chef (remote-exec): (Reading database ... 70%
    aws_instance.chef (remote-exec): (Reading database ... 75%
    aws_instance.chef (remote-exec): (Reading database ... 80%
    aws_instance.chef (remote-exec): (Reading database ... 85%
    aws_instance.chef (remote-exec): (Reading database ... 90%
    aws_instance.chef (remote-exec): (Reading database ... 95%
    aws_instance.chef (remote-exec): (Reading database ... 100%
    aws_instance.chef (remote-exec): (Reading database ... 51120 files and directories currently installed.)
    aws_instance.chef (remote-exec): Preparing to unpack .../liberror-perl_0.17-1.1_all.deb ...
    aws_instance.chef (remote-exec): Unpacking liberror-perl (0.17-1.1) ...
    aws_instance.chef (remote-exec): Selecting previously unselected package git-man.
    aws_instance.chef (remote-exec): Preparing to unpack .../git-man_1%3a1.9.1-1ubuntu0.1_all.deb ...
    aws_instance.chef (remote-exec): Unpacking git-man (1:1.9.1-1ubuntu0.1) ...
    aws_instance.chef (remote-exec): Selecting previously unselected package git.
    aws_instance.chef (remote-exec): Preparing to unpack .../git_1%3a1.9.1-1ubuntu0.1_amd64.deb ...
    aws_instance.chef (remote-exec): Unpacking git (1:1.9.1-1ubuntu0.1) ...
    aws_instance.chef (remote-exec): Processing triggers for man-db (2.6.7.1-1ubuntu1) ...
    aws_instance.chef (remote-exec): Setting up liberror-perl (0.17-1.1) ...
    aws_instance.chef (remote-exec): Setting up git-man (1:1.9.1-1ubuntu0.1) ...
    aws_instance.chef (remote-exec): Setting up git (1:1.9.1-1ubuntu0.1) ...
    aws_instance.chef (remote-exec): dpkg-deb: error: `chef_server.deb' is not a debian format archive
    aws_instance.chef (remote-exec): dpkg: error processing archive chef_server.deb (--install):
    aws_instance.chef (remote-exec):  subprocess dpkg-deb --control returned error exit status 2
    aws_instance.chef (remote-exec): Errors were encountered while processing:
    aws_instance.chef (remote-exec):  chef_server.deb
    aws_instance.chef (remote-exec): sudo: chef-server-ctl: command not found
    aws_instance.chef (remote-exec): sudo: chef-server-ctl: command not found
    aws_instance.chef (remote-exec): sudo: chef-server-ctl: command not found
    aws_instance.chef (remote-exec): sudo: opscode-manage-ctl: command not found
    aws_instance.chef (remote-exec): sudo: chef-server-ctl: command not found
    aws_instance.chef (remote-exec): sudo: chef-server-ctl: command not found
    aws_instance.chef (remote-exec): sudo: opscode-push-jobs-server-ctl: command not found
    aws_instance.chef (remote-exec): sudo: chef-server-ctl: command not found
    aws_instance.chef (remote-exec): sudo: chef-server-ctl: command not found
    aws_instance.chef (remote-exec): sudo: chef-sync-ctl: command not found
    aws_instance.chef (remote-exec): sudo: chef-server-ctl: command not found
    aws_instance.chef (remote-exec): sudo: chef-server-ctl: command not found
    aws_instance.chef (remote-exec): sudo: opscode-reporting-ctl: command not found
    Error applying plan:

    1 error(s) occurred:

     * Script exited with non-zero exit status: 1

    Terraform does not automatically rollback in the face of errors.
    Instead, your Terraform state file has been partially updated with
    any resources that successfully completed. Please address the error
    above and apply again to incrementally change your infrastructure.

    real    1m48.795s
    user    0m0.373s
    sys 0m0.341s
    [demo@demos-MBP:~/pdev/chef-practice/t2(master)]$ cd /tmp
    [demo@demos-MBP:/tmp]$ 
      C-c C-c
    [demo@demos-MBP:/tmp]$ 

DONE terraform can't force destroy, or how can I get terraform to destroy group first
-------------------------------------------------------------------------------------

CLOSED: \[2015-12-04 Fri 22:33\]

This was fixed in Terraform v0.6.8

When provisioning step fails, terraform is left in bad state where it
doesn't know the instance is still running, but it does know the
instance security group is present.

For this case, I'd want terraform to really force destory the security
group. Why can't it?

Here's what I do that will cause the terraform create/delete/create flow
to break:

Create main.tf with remote-exec that causes failure in provisioning.

TF will bail after creating the ubuntu instacne.

TF doesn't know whether the instacne was created successfully, but it
knows it created the security group.

    terraform plan -destroy -var-file=secrets.tfvars

Says that it will destroyt the security group, but when really
destroying it

    terraform destroy -var-file=secrets.tfvars

AWS complains that it can't destroy security group if an instacne is
using it.

I only know how to fix this by manually deleting the instance and
re-runing TF destroy.

terraform InvalidGroup.InUse destroy

    [demo@demos-MBP:~/pdev/chef-practice/t2(master)]$ terraform destroy -force -var-file=secrets.tfvars
    aws_instance.chef: Refreshing state... (ID: i-9b995741)
    aws_security_group.chef: Refreshing state... (ID: sg-3915bf0a)
    aws_instance.chef: Destroying...
    aws_security_group.chef: Destroying...
    Error applying plan:

    1 error(s) occurred:

     * aws_security_group.chef: InvalidGroup.InUse: There are active instances using security group 'chef'
        status code: 400, request id: 

    Terraform does not automatically rollback in the face of errors.
    Instead, your Terraform state file has been partially updated with
    any resources that successfully completed. Please address the error
    above and apply again to incrementally change your infrastructure.
    [demo@demos-MBP:~/pdev/chef-practice/t2(master)]$ 

ssh: handshake failed: ssh: unable to authenticate, attempted methods \[none publickey\], no supported methods remain
---------------------------------------------------------------------------------------------------------------------

terraform ssh: handshake failed: ssh: unable to authenticate, attempted
methods \[none publickey\], no supported methods remain terraform ssh:
handshake failed: ssh: unable to authenticate, attempted methods

    [demo@demos-MacBook-Pro:~/pdev/chef-practice/t2(master)]$ terraform apply -var-file=secrets.tfvars
    aws_security_group.chef: Creating...
      description:                          "" => "Allow ssh inbound traffic from everywhere"
      egress.#:                             "" => "<computed>"
      ingress.#:                            "" => "1"
      ingress.2541437006.cidr_blocks.#:     "" => "1"
      ingress.2541437006.cidr_blocks.0:     "" => "0.0.0.0/0"
      ingress.2541437006.from_port:         "" => "22"
      ingress.2541437006.protocol:          "" => "tcp"
      ingress.2541437006.security_groups.#: "" => "0"
      ingress.2541437006.self:              "" => "0"
      ingress.2541437006.to_port:           "" => "22"
      name:                                 "" => "chef"
      owner_id:                             "" => "<computed>"
      tags.#:                               "" => "1"
      tags.Name:                            "" => "chef"
      vpc_id:                               "" => "<computed>"
    aws_security_group.chef: Creation complete
    aws_instance.chef: Creating...
      ami:                                       "" => "ami-5189a661"
      availability_zone:                         "" => "<computed>"
      ebs_block_device.#:                        "" => "<computed>"
      ephemeral_block_device.#:                  "" => "<computed>"
      instance_type:                             "" => "m3.medium"
      key_name:                                  "" => "ephemeral-test"
      monitoring:                                "" => "1"
      placement_group:                           "" => "<computed>"
      private_dns:                               "" => "<computed>"
      private_ip:                                "" => "<computed>"
      public_dns:                                "" => "<computed>"
      public_ip:                                 "" => "<computed>"
      root_block_device.#:                       "" => "1"
      root_block_device.0.delete_on_termination: "" => "1"
      root_block_device.0.iops:                  "" => "<computed>"
      root_block_device.0.volume_size:           "" => "100"
      root_block_device.0.volume_type:           "" => "<computed>"
      security_groups.#:                         "" => "1"
      security_groups.4064823014:                "" => "chef"
      source_dest_check:                         "" => "1"
      subnet_id:                                 "" => "<computed>"
      tags.#:                                    "" => "1"
      tags.Name:                                 "" => "chef"
      tenancy:                                   "" => "<computed>"
      vpc_security_group_ids.#:                  "" => "<computed>"
    aws_instance.chef: Provisioning with 'file'...
    pwd
    Error applying plan:

    1 error(s) occurred:

     * ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey], no supported methods remain

    Terraform does not automatically rollback in the face of errors.
    Instead, your Terraform state file has been partially updated with
    any resources that successfully completed. Please address the error
    above and apply again to incrementally change your infrastructure.
    [demo@demos-MacBook-Pro:~/pdev/chef-practice/t2(master)]$ /Users/demo/pdev/chef-practice/t2
    [demo@demos-MacBook-Pro:~/pdev/chef-practice/t2(master)]$

