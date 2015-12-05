#!/bin/sh

set -x

# Clean, update machine
sudo rm /var/lib/apt/lists/* -vf
sudo apt-get clean
sudo apt-get autoremove
sudo apt-get -qq update

sudo apt-get -qq install --assume-yes git

# Install Chef server and packages
cd /tmp
curl -Lo chef-server-core_12.3.1-1_amd64.deb https://packagecloud.io/chef/stable/packages/ubuntu/precise/chef-server-core_12.3.1-1_amd64.deb/download
sudo dpkg -i chef-server-core_12.3.1-1_amd64.deb
sudo chef-server-ctl reconfigure

# Chef Manage
sudo chef-server-ctl install opscode-manage
sudo chef-server-ctl reconfigure
sudo opscode-manage-ctl reconfigure

# Chef Push Jobs
sudo chef-server-ctl install opscode-push-jobs-server
sudo chef-server-ctl reconfigure
sudo opscode-push-jobs-server-ctl reconfigure

# Chef replication
sudo chef-server-ctl install chef-sync
sudo chef-server-ctl reconfigure
sudo chef-sync-ctl reconfigure

# Reporting
sudo chef-server-ctl install opscode-reporting
sudo chef-server-ctl reconfigure
sudo opscode-reporting-ctl reconfigure
