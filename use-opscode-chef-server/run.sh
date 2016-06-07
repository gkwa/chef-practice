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
git add .
git commit -m "Add app"

##############################
# setup for chef server
cd $root/aar

rm -rf .chef
mkdir -p .chef

##############################
chef generate cookbook cookbooks/motd_rhel
chef generate template cookbooks/motd_rhel server-info
# manually edit according to:
# https://learn.chef.io/local-development/rhel/get-started-with-test-kitchen/#writethedefaultrecipe

# cp ~/Downloads/knife.rb .chef
cat <<'__EOT__' >$root/aar/.chef/knife.rb
# See http://docs.chef.io/config_rb_knife.html for more information on knife configuration options
current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "mtm1"
client_key               "#{current_dir}/mtm1.pem"
validation_client_name   "streambox-validator"
validation_key           "#{current_dir}/streambox-validator.pem"
chef_server_url          "https://api.chef.io/organizations/streambox"
cookbook_path            ["#{current_dir}/../cookbooks"]
__EOT__


cp ~/Downloads/mtm1.pem ~/Downloads/streambox-validator.pem $root/aar/.chef
cd $root/aar/

set +e
knife node delete myserver -y
knife client delete myserver -y
set -e

cd $root/aar/cookbooks/motd_rhel

# kitchen create
cat <<'__EOT__' >recipes/default.rb
template '/etc/motd' do
  source 'server-info.erb'
  mode '0644'
end
__EOT__

cat <<'__EOT__' >templates/default/server-info.erb
hostname:  <%= node['hostname'] %>
fqdn:      <%= node['fqdn'] %>
memory:    <%= node['memory']['total'] %>
cpu count: <%= node['cpu']['total'] %>
__EOT__

##############################
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
#    chef.validation_key_path = "#{current_dir}/.chef/streambox-validator.pem"
    chef.validation_key_path = "/Users/demo/pdev/TaylorMonacelli/chef-practice/use-opscode-chef-server/aar/.chef/streambox-validator.pem"
    chef.validation_client_name = "streambox-validator"
    chef.node_name = "myserver"

    # https://www.vagrantup.com/docs/provisioning/chef_common.html
    # not working as expected.  Does bento/ubuntu-14.04 already have
    # chef client installed?  If so, then chef.version = "latest" should leave
    # the current one and not download the latest.
    # chef.version = "latest"

    chef.delete_node = true
    chef.delete_client = true
  end

  # Don't keep reinstalling virtualbox guest additions, it takes too
  # much time
  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = false
  end

  # Cache the chef client omnibus installer to speed up testing
  if Vagrant.has_plugin?("vagrant-omnibus")
    config.omnibus.cache_packages = true
# http://stackoverflow.com/a/18213542/1495086
	config.omnibus.chef_version = '12.10.24'
  end
end
__EOT__
git add VagrantAdditionalConfig.rb

##############################
cat <<'__EOT__' >.kitchen.local.yml
---
provisioner:
  chef_omnibus_install_options: '-d /tmp/vagrant-cache/vagrant_omnibus'
__EOT__
git add --force .kitchen.local.yml
git commit -a -m 'Add .kitchen.local.yml'

##############################

cat <<'__EOT__' >.kitchen.yml
---
driver:
  name: vagrant
  vagrantfiles:
    - VagrantAdditionalConfig.rb #Vagrantfiles must have a .rb extension to satisfy Ruby's Kernel#require.
  vm_hostname: myserver

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
__EOT__

##############################
git add .kitchen.yml
git commit -a -m 'updated .kitchen.yml'
# kitchen converge centos -p
# kitchen converge freebsd-9 -p
# kitchen converge -p

cd $root/aar
# upload cookbook to server
knife cookbook upload motd_rhel

# Can't do this before vagrant up
# vagrant up creates myserver client, node on opscode's chef server
# knife node run_list add myserver 'recipe[motd_rhel]'
