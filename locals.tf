
locals {

  attributes-json = "${data.template_file.attributes-json.rendered}"

  chef_ssl_cert         = "${var.chef_ssl["cert"] == "" ? ".chef/${var.instance["hostname"]}.${var.instance["domain"]}.pem" : var.chef_ssl["cert"]}"
  chef_ssl_private_key  = "${var.chef_ssl["key"]  == "" ? ".chef/${var.instance["hostname"]}.${var.instance["domain"]}.key" : var.chef_ssl["key"]}"


  #TODO generate this
  config = "${var.config}"

  # Vars after instance is provisioned
  user = "${module.chef-server.user}"
  key_file_private = "${module.chef-server.key_file_private}"
  public_ip        = "${element(module.chef-server.public_ip, 0)}"
  public_dns       = "${element(module.chef-server.public_dns, 0)}"
}
