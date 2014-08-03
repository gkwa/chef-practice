# http://gettingstartedwithchef.com/first-steps-with-chef.html
# usage: curl -L https://raw.githubusercontent.com/TaylorMonacelli/chef-practice/master/t1/t1.sh | sudo bash

sudo apt-get update
sudo apt-get install -y emacs git

curl -L https://www.opscode.com/chef/install.sh | sudo bash
chef-solo -v

wget http://github.com/opscode/chef-repo/tarball/master
tar -zxf master
mv opscode-chef-repo* chef-repo
rm master

cd chef-repo
mkdir .chef
echo "cookbook_path [ '/home/ubuntu/chef-repo/cookbooks' ]" > .chef/knife.rb
knife cookbook create phpapp

cd cookbooks
knife cookbook site download apache2
tar zxf apache2*
rm apache2*.tar.gz
knife cookbook site download apt
tar zxf apt*
rm apt*.tar.gz
knife cookbook site download iptables
tar zxf iptables*
rm iptables*.tar.gz
knife cookbook site download logrotate
tar zxf logrotate*
rm logrotate*.tar.gz
knife cookbook site download pacman
tar zxf pacman*
rm pacman*.tar.gz
knife cookbook site download freebsd
tar zxf freebsd*
rm freebsd*.tar.gz

##############################

cat << __EOT__ >>/home/ubuntu/chef-repo/cookbooks/phpapp/metadata.rb

depends "apache2", "2.2"
__EOT__

##############################

cat << __EOT__ >>/home/ubuntu/chef-repo/cookbooks/phpapp/recipes/default.rb

include_recipe "apache2"

apache_site "default" do
  enable true
end
__EOT__

##############################

cat << __EOT__ >>/home/ubuntu/chef-repo/solo.rb

file_cache_path "/home/ubuntu/chef-solo"
cookbook_path "/home/ubuntu/chef-repo/cookbooks"
__EOT__

##############################

cat << __EOT__ >>/home/ubuntu/chef-repo/web.json

{
  "run_list": [ "recipe[apt]", "recipe[phpapp]" ]
}
__EOT__

##############################

cd ~/chef-repo
chef-solo -c solo.rb -j web.json
