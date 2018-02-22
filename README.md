Chef Server - AWS Terraform module
==================================



Terraform module to create a standalone Chef server EC2 instance on AWS.

This module can be used by either passing a "Config map" to the module or standard module variables
the reason to use the Config map option is to simplify the number of variables which need to be passed to the module and also opens up the possibility to using third party key/value stores (Consul) ie dynamically generate a map of key/values passing a map of variables to the module.


Usage
-----


Example using variables
```hcl
module "my_ec2_instance" {
  source = "https://github.com/NetworkBytes/tf-app-chef-aws"

  config = {
    name = "chef-server"
    subnet_id = "subnet-123456"
    vpc_security_group_ids = "sg-123456,sg-7891011"
  }
  ...
}
```




Examples
--------

* [Example Using a Config Map](https://github.com/NetworkBytes/tf-app-chef-aws/tree/master/examples/configmap)

Inputs
---------
gererated by terraform-docs

| Name | Description | Type | Default |
|------|-------------|:----:|:-----:|
| allowed_cidrs | List of CIDRs to allow SSH from (CSV list allowed) | string | `0.0.0.0/0` |
| chef_addons | Comma seperated list of addons to install. Default: `manage,push-jobs-server,reporting` | string | `manage,push-jobs-server,reporting` |
| chef_log | Log chef provisioner to file | string | `true` |
| chef_org | Chef organization settings | map | `<map>` |
| chef_ssl | Chef server SSL settings | map | `<map>` |
| chef_user | Chef user settings | map | `<map>` |
| chef_versions | Chef software versions | map | `<map>` |
| instance | EC2 instance host settings | map | `<map>` |
| instance_flavor | EC2 instance flavor (type). Default: c3.xlarge | string | `c3.xlarge` |

Outputs
---------

| Name | Description |
|------|-------------|


Limitations
-----------


Authors
-------

Module managed by [John Bencic / NetworkBytes](https://github.com/NetworkBytes).
  
License
-------

MIT Licensed. See LICENSE for full details.

