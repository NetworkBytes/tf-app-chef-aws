
locals {

  user_data = "${data.template_file.user_data.rendered}"
  config = {
    name = "chef-server"
    subnet_id = "subnet-a0de23f9"
    vpc_security_group_ids = "sg-8233e0e4,sg-090cdf6f"
    associate_public_ip_address = "true"
    user_data = "${local.user_data}"
  }

}
