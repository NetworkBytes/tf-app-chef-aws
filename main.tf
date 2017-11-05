

module "chef-server" {
  source = "github.com/NetworkBytes/tf-module-aws-vm"
  config = "${local.config}"
}


#TODO
# support count

resource "null_resource" "chef-server_configure" {
  triggers {
    chef-server_instance_ids = "${join(",", module.chef-server.id)}"
  }

  connection {
    host = "${element(module.chef-server.public_ip, 0)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo I worked"
    ]
  }
}