set -e


vagrant_box=ubuntu/trusty64 # Ubuntu 14.04

# https://downloads.chef.io/chef-server/ubuntu/
baseurl=https://packages.chef.io/stable/ubuntu/14.04
chef_installer=chef-server-core_12.5.0-1_amd64.deb



d=chef$(date +%S%H)
base=tmp
mkdir -p $base/$d

cd $base/$d

cat <<__EOF__ >Vagrantfile
Vagrant.configure(2) do |config|
  config.vm.box = "$vagrant_box"

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048 # default 500 isn't enough
#    v.cpus = 1
  end

  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
  end

  # fail if vagrant-host-shell plugin is not yet installed
  unless Vagrant.has_plugin?("vagrant-host-shell")
    raise 'vagrant plugin "vagrant-host-shell" is not installed, run "vagrant plugin install vagrant-host-shell"'
  end

  # prevent having to download huge deb file repeatedly
  config.vm.provision :host_shell do |host_shell|
    # /vagrant is mounted to same dir as Vagrantfile, so copy deb here
    host_shell.inline = 'wget -NP ../.. $baseurl/$chef_installer'
    host_shell.inline = 'cp ../../$chef_installer .'
  end

  config.vm.provision :shell, :inline => <<__VM_PROVISION__
sudo dpkg -i /vagrant/$chef_installer
sudo chef-server-ctl reconfigure
sudo apt-get install -y git
__VM_PROVISION__
end
__EOF__

vagrant up
