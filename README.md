Chef Server - AWS Terraform module
==================================



Terraform module to create a standalone Chef server EC2 instance on AWS.

This module can be used by either passing a "Config map" to the module or standard module variables
the reason to use the Config map option is to simplify the number of variables which need to be passed to the module and also opens up the possibility to using third party key/value stores (Consul) ie dynamically generate a map of key/values passing a map of variables to the module.

This module will eventually support bothe Windows and Linux operating systems as well as using Chef or Puppet as the configuration management system 

Usage
-----


Example using variables
```hcl
module "my_ec2_instance" {
  source = "https://github.com/NetworkBytes/tf-module-aws-vm"

  name  = "my-ec2"
  count = 1
  
  key_name               = "user1"
  vpc_security_group_ids = ["sg-12345678"]
  ...
}
```


Example using Config Map
```hcl
module "my_ec2_instance" {
  source = "https://github.com/NetworkBytes/tf-module-aws-vm"
  
  config = {
    name  = "my-ec2"
    count = 1
    ...
  }
}
```


Examples
--------

* [Basic EC2 instance](https://github.com/NetworkBytes/tf-module-aws-vm/tree/master/examples/basic)

Inputs
---------
gererated by terraform-docs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami | ID of AMI to use for the instance | string | `` | no |
| ami_name | The name of the Amazon AMI image to use; defaults dependent on var.os, an OS of windows defaults to Windows_Server-2016-English-Full-Base-*, linux defaults to TODO | map | `<map>` | no |
| appid |  | string | `` | no |
| associate_public_ip_address | If true, the EC2 instance will have associated public IP address | string | `false` | no |
| availability_zone | The AZ to start the instance in | string | `` | no |
| aws_region | The configuration management role to apply to this host | string | `ap-southeast-2` | no |
| cm_client_key | The configuration management key to use when connecting to the master server | string | `` | no |
| cm_client_name |  | string | `` | no |
| cm_flavour | The configuration management software to use; valid options Puppet / Chef | string | `chef` | no |
| cm_hostname |  | string | `` | no |
| cm_master | The configuration management master host or ip to use when configuring an instance; defaults to "cm_flavour" eg puppet | string | `` | no |
| cm_role | The configuration management role to apply to this host | string | `web_server` | no |
| config | Config Map which can be passed to this module | map | `<map>` | no |
| count | Number of instances to launch | string | `1` | no |
| ebs_block_device | Additional EBS block devices to attach to the instance | string | `` | no |
| environment |  | string | `dev` | no |
| iam_instance_profile | The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. | string | `` | no |
| instance_type | The type of instance to start; defaults to "t2.micro" | string | `t2.micro` | no |
| key_file | The path to the ssh key file to use for connecting to the instance; default "~/.ssh/id_rsa.pub" | string | `~/.ssh/id_rsa.pub` | no |
| key_file_private | The path to the ssh private key file to use for connecting to the instance; default "~/.ssh/id_rsa" | string | `~/.ssh/id_rsa` | no |
| key_name | The key name to use for the instance | string | `` | no |
| name | Name to be used on all resources as prefix | string | `` | no |
| os | Operating systems to deploy; valid options are "windows" or "linux" | string | `linux` | no |
| placement_group | The Placement Group to start the instance in | string | `` | no |
| private_ip | Private IP address to associate with the instance in a VPC | string | `` | no |
| root_block_device | Customize details about the root block device of the instance. See Block Devices below for details | string | `` | no |
| subnet_id | The VPC Subnet ID to launch in | string | `` | no |
| user | The provisioner connection user; defaults to centos for linux and Administrator for windows | string | `` | no |
| user_data | The user data to provide when launching the instance | string | `` | no |
| vpc_security_group_ids | A list of security group IDs to associate with | string | `` | no |

Outputs
---------

| Name | Description |
|------|-------------|
| availability_zone | List of availability zones of instances |
| id | List of IDs of instances |
| key_name | List of key names of instances |
| network_interface_id | List of IDs of the network interface of instances |
| placement_group | List of placement groups of instances |
| primary_network_interface_id | List of IDs of the primary network interface of instances |
| private_dns | List of private DNS names assigned to the instances. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC |
| private_ip | List of private IP addresses assigned to the instances |
| public_dns | List of public DNS names assigned to the instances. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC |
| public_ip | List of public IP addresses assigned to the instances, if applicable |
| security_groups | List of associated security groups of instances |
| subnet_id | List of IDs of VPC subnets of instances |
| vpc_security_group_ids | List of associated security groups of instances, if running in non-default VPC |


Limitations
-----------


Authors
-------

Module managed by [John Bencic / NetworkBytes](https://github.com/NetworkBytes).
  
License
-------

MIT Licensed. See LICENSE for full details.

