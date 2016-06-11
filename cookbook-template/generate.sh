#!/bin/bash

set -e

repo_name="${1:-chef-repo}"
cookbook_name="${2:-mycookbook}"

root=`pwd`

rm -rf $repo_name
chef generate repo $repo_name
cd $repo_name
git add -A
git commit -am "Templated repo"

rm -rf cookbooks/example
git add -A
git commit -am "Remove templated example cookbok"
# --generator-arg "maintainer='taylor monacelli'" # not working
# chef generate cookbook --generator-arg "maintainer='taylor monacelli'" --email taylor.monacelli@streambox.com cookbooks/$cookbook_name
chef generate cookbook --email taylor.monacelli@streambox.com cookbooks/$cookbook_name
git add -A
git commit -am "Templated cookbook"

(cd cookbooks/$cookbook_name && ruby -r yaml -e "data = YAML.load_file '.kitchen.yml';File.open('.kitchen.yml', 'w') { |f| YAML.dump(data, f) }")
git add -A
git commit -am "whitespace"
git rebase --whitespace=fix HEAD~1

cd cookbooks/$cookbook_name
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

  # Don't keep reinstalling virtualbox guest additions, it takes too
  # much time
  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = false
  end

  # Cache the chef client omnibus installer to speed up testing
  if Vagrant.has_plugin?("vagrant-omnibus")
    config.omnibus.cache_packages = true
    config.omnibus.chef_version = '12.10.24'
  end
end
__EOT__
git add VagrantAdditionalConfig.rb
ruby -r yaml -e "data = YAML.load_file '.kitchen.yml';data['driver']['vagrantfiles']=['VagrantAdditionalConfig.rb'];data['provisioner']['chef_omnibus_install_options']='-d /tmp/vagrant-cache/vagrant_omnibus';File.open('.kitchen.yml', 'w') { |f| YAML.dump(data, f) }"
git commit -am "Save bandwidth by caching as much as possible"
git rebase --whitespace=fix HEAD~1

# fixme: parameterize this: config.omnibus.chef_version = '12.10.24' from Vagrant file.  It was set in previous commit, maybe use ruby include?
ruby -r yaml -e "data = YAML.load_file '.kitchen.yml';data['driver']['vagrantfiles']=['VagrantAdditionalConfig.rb'];data['provisioner']['require_chef_omnibus']='12.10.24';File.open('.kitchen.yml', 'w') { |f| YAML.dump(data, f) }"
TMPFILE=`mktemp '/tmp/generage.sh.XXX'`
cat <<'__EOT__' >$TMPFILE
Heed warning: You are installing an omnibus package without a version pin

WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING

You are installing an omnibus package without a version pin.  If you are installing
on production servers via an automated process this is DANGEROUS and you will
be upgraded without warning on new releases, even to new major releases.
Letting the version float is only appropriate in desktop, test, development or
CI/CD environments.

WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING
__EOT__
git commit -a -F $TMPFILE
git rebase --whitespace=fix HEAD~1

cd $root

#   Assign a remote upload repository for just cookbook
cd $repo_name/cookbooks/$cookbook_name
git init
git remote add origin git@gitlab.com':'taylormonacelli/$cookbook_name
git add -A
git commit -am "Initial cookbook $cookbook_name"

cd $root

#   Assign a remote upload repository for repo
cd $repo_name
git remote add origin git@gitlab.com':'taylormonacelli/$repo_name
