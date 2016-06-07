: <<COMMENTBLOCK
Script combines many ideas mostly with the goal to lear test-kitchen to
test cookbooks.

https://www.chef.io/blog/2015/08/18/policyfiles-a-guided-tour
https://blog.talkingtotheduck.ca/how-to/2015/12/13/vagrant-cachier-with-test-kitchen
https://github.com/test-kitchen/kitchen-vagrant

https://learn.chef.io/local-development/rhel/get-started-with-test-kitchen/
https://manage.chef.io/organizations/streambox/users/mtm1
https://manage.chef.io/organizations/streambox

COMMENTBLOCK
set -e

pushd `dirname $0` >/dev/null
root=`pwd`
popd >/dev/null

##############################
# ensure vagrant plugins are installed
vagrant plugin list|awk '{print $1}' >./plugins

for vp in vagrant-vbguest vagrant-cachier vagrant-omnibus
do
	if ! grep $vp ./plugins
	then
		vagrant plugin install $vp
	fi
done
rm -f ./plugins
##############################

vboxmanage list vms | ack '{(.*)}' ack --output='vboxmanage controlvm $1 poweroff; vboxmanage unregistervm $1 --delete' | sh -x -

[ -d aar ] && (cd aar && kitchen destroy all)
rm -rf aar
mkdir aar
cd aar
chef generate app .
# Policyfiles will be the default someday, 'till then:
chef generate policyfile

git add .
git commit -m 'initial policyfile demo commit'

##############################
# setup for chef server
cd $root/aar
rm -rf .chef
mkdir -p .chef
cp ~/Downloads/knife.rb .chef
cp ~/Downloads/mtm1.pem ~/Downloads/streambox-validator.pem .chef

##############################
chef generate cookbook cookbooks/motd_rhel
chef generate template cookbooks/motd_rhel server-info
# manually edit according to:
# https://learn.chef.io/local-development/rhel/get-started-with-test-kitchen/#writethedefaultrecipe
cd cookbooks/motd_rhel
# kitchen create

# aar/cookbooks/motd_rhel
cd $root/aar

# upload cookbook to server
knife cookbook upload motd_rhel

# check its uploaded
# https://manage.chef.io/organizations/streambox/cookbooks

knife node run_list add myserver 'recipe[motd_rhel]'
##############################

cat <<'__EOT__' >>cookbooks/aar/metadata.rb
depends "chef-client"
depends "apt"
depends "ntp"
depends "users"
__EOT__

cat <<'__EOT__' >>cookbooks/aar/recipes/default.rb
include_recipe "chef-client"
include_recipe "apt"
include_recipe "ntp"
include_recipe "users"

users_manage 'testgroup' do
  group_id 3000
  action [:create]
  data_bag 'test_home_dir'
end
__EOT__

##############################

# policyfile

cat <<'__EOT__' >Policyfile.rb
# Policyfile.rb - Describe how you want Chef to build your system.
#
# For more information on the Policyfile feature, visit
# https://github.com/opscode/chef-dk/blob/master/POLICYFILE_README.md

# A name that describes what the system you're building with Chef does.
name "aar"

# Where to find external cookbooks:
default_source :community

# run_list: chef-client will run these recipes in the order specified.
run_list "aar::default"

# Specify a custom source for a single cookbook:
cookbook "aar", path: "cookbooks/aar"

__EOT__

##############################
knife cookbook create irc -o cookbooks

cat <<'__EOT__' >>cookbooks/irc/recipes/default.rb
user 'tdi' do
	action :create
	comment "Test Driven Infrastructure"
	home "/home/tdi"
	manage_home true
end
__EOT__

cat <<'__EOT__' >>Policyfile.rb
# run_list: chef-client will run these recipes in the order specified.
run_list "irc::default"

# Specify a custom source for a single cookbook:
cookbook "irc", path: "cookbooks/irc"
__EOT__
##############################

chef install

git add Policyfile.lock.json
git commit -a -m 'updated Policyfile and created lock'

cat <<'__EOT__' >VagrantAdditionalConfig.rb
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Cache apt, rpm, gems, ... as much as I can to speed up testing
  if Vagrant.has_plugin?('vagrant-cachier')
#    config.cache.auto_detect = true # prefer to be explicit
    config.cache.scope = :box
	config.cache.enable :pacman
	config.cache.enable :rvm
	config.cache.enable :chef
	config.cache.enable :yum
	config.cache.enable :apt
	config.cache.enable :gem
  end

  current_dir = File.dirname(__FILE__)
  config.vm.provision "chef_client" do |chef|
    chef.chef_server_url = "https://api.opscode.com/organizations/streambox"
    chef.validation_key_path = "#{current_dir}/.chef/streambox-validator.pem"
    chef.validation_client_name = "streambox-validator"
  end

  # Don't keep reinstalling virtualbox guest additions, it takes too
  # much time
  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = false
  end

  # Cache the chef client omnibus installer to speed up testing
  if Vagrant.has_plugin?("vagrant-omnibus")
    config.omnibus.cache_packages = true
  end
end
__EOT__
git add VagrantAdditionalConfig.rb


cat <<'__EOT__' >.kitchen.local.yml
---
provisioner:
  chef_omnibus_install_options: '-d /tmp/vagrant-cache/vagrant_omnibus'
__EOT__
git add --force .kitchen.local.yml
git commit -a -m 'Add .kitchen.local.yml'

cat <<'__EOT__' >.kitchen.yml
---
driver:
  name: vagrant
#  network:
#    - ["forwarded_port", {guest: 80, host: 8080}]
  vagrantfiles:
    - VagrantAdditionalConfig.rb #Vagrantfiles must have a .rb extension to satisfy Ruby's Kernel#require.

provisioner:
  name: chef_zero
  require_chef_omnibus: 12.10.24

platforms:
  - name: ubuntu-12.04
  - name: ubuntu-14.04
  - name: centos-5.11
  - name: centos-6.7
  - name: centos-7.2
  - name: debian-7.9
  - name: debian-8.3
#  - name: freebsd-9.3 # uncomment this if you remove vagrant-cachier from Vagrantfile
#  - name: freebsd-10.2 # uncomment this if you remove vagrant-cachier from Vagrantfile
#  - name: fedora-22 # vagrant-cachier 1.2.1 doesn't know fedora uses and there is no /etc/yum.conf
#  - name: fedora-23 # vagrant-cachier 1.2.1 doesn't know fedora uses and there is no /etc/yum.conf

suites:
  - name: default
    attributes:
__EOT__




git add .kitchen.yml
git commit -a -m 'updated .kitchen.yml'
# kitchen converge centos -p
# kitchen converge freebsd-9 -p
# kitchen converge -p
