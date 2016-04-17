#!/bin/sh

set -x

export DEBIAN_FRONTEND=noninteractive

# Clean, update machine
sudo rm /var/lib/apt/lists/* -vf
sudo apt-get clean
sudo apt-get autoremove
sudo apt-get -qq update

sudo apt-get -qq install --assume-yes git

cd /tmp

# Install Chef server and packages
# https://downloads.chef.io/chef-server/ubuntu/
curl -LO https://packages.chef.io/stable/ubuntu/14.04/chef-server-core_12.5.0-1_amd64.deb
sudo dpkg -i chef-server-*_*_*.deb
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
