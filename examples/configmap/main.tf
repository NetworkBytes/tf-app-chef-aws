
locals {

  # This is just a hardcoded sample however the config can get generated 
  # from any key/value store eg consul for a given host

  config = {
    name = "chef-server"
    subnet_id = "subnet-a0de23f9"
    vpc_security_group_ids = "sg-8233e0e4,sg-090cdf6f"
    associate_public_ip_address = "true"
    instance_type = "t2.large"
  }
}


module "Chef_Server_instance" {
  source = "../../"
  config = "${local.config}"
}
