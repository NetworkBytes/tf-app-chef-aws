
locals {

  attributes-json = "${data.template_file.attributes-json.rendered}"

  chef_ssl = {
    type          = "map"
    default       = {
      file_base   = ".chef/${var.instance["hostname"]}.${var.instance["domain"]}"
      cert        = "${var.chef_ssl["cert"] == "" ? "${local.chef_ssl["file_base"]}.cert" : var.chef_ssl["cert"]}"
      key         = "${var.chef_ssl["key"]  == "" ? ".${local.chef_ssl["file_base"]}.key"  : var.chef_ssl["key"]}"
    }
  }


  #TODO generate sg's and subnets
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
