#!/bin/sh

set -x

export DEBIAN_FRONTEND=noninteractive

# Clean, update machine
sudo rm /var/lib/apt/lists/* -vf
sudo apt-get clean
sudo apt-get autoremove
sudo apt-get -qq update

sudo apt-get -qq install --assume-yes git

# Install Chef server and packages
# https://downloads.chef.io/chef-server/ubuntu/
cd /tmp
curl -L https://omnitruck.chef.io/install.sh | sudo bash
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

# Install knife and chef client tools
sudo apt-get install -y chef
