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
- curl -L https://supermarket.chef.io/cookbooks/chef-server/download | sudo tar xvzC /var/chef/cookbooks

# pull down dependency cookbooks
- curl -L https://supermarket.chef.io/cookbooks/chef-ingredient/download | sudo tar xvzC /var/chef/cookbooks

# create config json
- 


# GO
#- sudo chef-solo -o 'recipe[chef-server::default]'
- |
  echo '{
    "chef-server": {
      "configuration": "notification_email 'chef-server@example.com'\n
      nginx['cache_max_size'] = '3500m'"
      }
    }'|
  chef-solo -j /dev/stdin -o 'recipe[chef-server::default]'



# Capture all subprocess output into a logfile
# Useful for troubleshooting cloud-init issues
output: {all: '| tee -a /var/log/cloud-init-output.log'}