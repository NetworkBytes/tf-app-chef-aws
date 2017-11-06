
locals {

  attributes-json = "${data.template_file.attributes-json.rendered}"

  config = {
    name = "chef-server"
    subnet_id = "subnet-a0de23f9"
    vpc_security_group_ids = "sg-8233e0e4,sg-090cdf6f"
    associate_public_ip_address = "true"
    instance_type = "t2.large"
  }

  # Vars after instance is provisioned
  user = "${module.chef-server.user}"
  key_file_private = "${module.chef-server.key_file_private}"
  public_ip        = "${element(module.chef-server.public_ip, 0)}"
  public_dns       = "${element(module.chef-server.public_dns, 0)}"
}
