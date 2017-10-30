#cloud-config
#package_upgrade: true
#packages:
#- vim
#- mailx
runcmd:
- sudo yum install -y git yum-utils
# https://github.com/chef-cookbooks/chef-server

# install chef-solo
- curl -L https://www.chef.io/chef/install.sh | sudo bash

# create required bootstrap dirs/files
- sudo mkdir -p /var/chef/cache /var/chef/cookbooks

# pull down this chef-server cookbook
- wget -qO- https://supermarket.chef.io/cookbooks/chef-server/download | sudo tar xvzC /var/chef/cookbooks

# pull down dependency cookbooks
- wget -qO- https://supermarket.chef.io/cookbooks/chef-ingredient/download | sudo tar xvzC /var/chef/cookbooks

# GO
- sudo chef-solo -o 'recipe[chef-server::default]'




# Capture all subprocess output into a logfile
# Useful for troubleshooting cloud-init issues
output: {all: '| tee -a /var/log/cloud-init-output.log'}