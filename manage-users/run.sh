#!/bin/bash

set -e

repo=${1:-userstest}
cookbook=${2:-my_users}

../cookbook-template/generate.sh ${repo} ${cookbook}

cd ${repo}

knife cookbook site install users --cookbook-path cookbooks
knife cookbook site install sudo --cookbook-path cookbooks
knife cookbook upload --all --cookbook-path cookbooks

mkdir -p data_bags/users
knife data bag list |
	while read bag; do
		knife data bag delete --yes $bag;
	done

# this creates users data bag on server (not locally on
# workstation/MBP):
knife data_bag create users

# han.json
cat <<'__EOT__' >data_bags/users/han.json
{
  "id"       : "han",
  "comment"  : "Han Solo",
  "home"     : "/opt/carbonite",
  "groups"   : ["rebels", "scoundrels", "sysadmin"],
  "ssh_keys" : [
    "AAA123...xyz== foo",
    "AAA456...uvw== bar"
  ]
}
__EOT__

# leia.json
cat <<'__EOT__' >data_bags/users/leia.json
{
  "id"       : "leia",
  "groups"   : ["rebels", "your_worship"],
  "action"   : "remove"
}
__EOT__

# chewbacca.json
cat <<'__EOT__' >data_bags/users/chewbacca.json
{
  "id"       : "chewbacca",
  "comment"  : "What A Wookie!",
  "home"     : "/home/kashyyyk",
  "groups"   : ["rebels", "sidekicks"],
  "action"   : ["create", "lock"]
}
__EOT__

# vader.json
cat <<'__EOT__' >data_bags/users/vader.json
{
  "id"       : "vader",
  "comment"  : "Anakin was a crybaby",
  "groups"   : ["empire", "siths", "sysadmin" ],
  "ssh_keys" : [
    "AAA789...abc== baz"
  ]
}
__EOT__

# fixme: we shouldn't put these databags in the coookbook
git add data_bags/users
git commit -am "Add user databags"

knife data bag from file users data_bags/users/*

# knife cookbook create ${cookbook} --cookbook-path cookbooks
# above replaced with: make repo=${repo} cookbook=${cookbook}

cat <<'__EOT__' >>cookbooks/${cookbook}/metadata.rb

depends 'users'
depends 'sudo'
__EOT__

cat <<'__EOT__' >>cookbooks/${cookbook}/recipes/default.rb

users_manage "rebels" do
   group_id 1138
   action [ :remove, :create ]
end
__EOT__

(cd cookbooks/${cookbook}
git commit -am "Add recipe")

# idea from
# https://github.com/chef-cookbooks/users/blob/master/.kitchen.yml fixes
# https://github.com/taylormonacelli/chef-practice/manage-users/README.org
(cd cookbooks/${cookbook}
ruby -r yaml -e "data = YAML.load_file '.kitchen.yml';data['suites'][0]['data_bags_path']='../../data_bags';File.open('.kitchen.yml', 'w') { |f| YAML.dump(data, f) }"
git commit -am "Path to databags"
git rebase --whitespace=fix HEAD~1
)

(cd cookbooks/${cookbook}
ruby -r yaml -e "data = YAML.load_file '.kitchen.yml';data['platforms'][0]['name']='ubuntu-14.04';File.open('.kitchen.yml', 'w') { |f| YAML.dump(data, f) }"
git commit -am "Fails on ubuntu 16.04, so converge on ubuntu 14.04 instaed"
git rebase --whitespace=fix HEAD~1
)

knife cookbook upload --cookbook-path cookbooks --all
