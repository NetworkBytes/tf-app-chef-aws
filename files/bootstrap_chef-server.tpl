sudo yum install -y git yum-utils
# https://github.com/chef-cookbooks/chef-server

# install chef-solo
#- curl -L https://www.chef.io/chef/install.sh | sudo bash

# create required bootstrap dirs/files
#- sudo mkdir -p /var/chef/cache /var/chef/cookbooks

# pull down this chef-server cookbook
#- curl -L https://supermarket.chef.io/cookbooks/chef-server/download | sudo tar xvzC /var/chef/cookbooks

# pull down dependency cookbooks
#- curl -L https://supermarket.chef.io/cookbooks/chef-ingredient/download | sudo tar xvzC /var/chef/cookbooks

# create config json


# GO
#- sudo chef-solo -o 'recipe[chef-server::default]'

