

module "chef-server" {
  source = "github.com/NetworkBytes/tf-module-aws-vm"
  config = "${local.config}"
}


#
# Local prep
#
resource "null_resource" "chef-prep" {
  provisioner "local-exec" {
    command = <<-EOF
      [ -f .chef/encrypted_data_bag_secret ] && rm -f .chef/encrypted_data_bag_secret
      openssl rand -base64 512 | tr -d '\r\n' > .chef/encrypted_data_bag_secret
      echo "Local prep complete"
      EOF
  }
}





resource "null_resource" "chef-server_configure" {
  triggers {
    chef-server_instance_ids = "${join(",", module.chef-server.id)}"
  }

  connection {
    host        = "${local.public_ip}"
    user        = "${local.user}"
    private_key = "${file(pathexpand(local.key_file_private))}"

  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl disable firewalld",
      "sudo systemctl stop firewalld",

      "mkdir -p .chef",
      "curl -L https://omnitruck.chef.io/install.sh | sudo bash -s -- -v ${var.chef_versions["client"]}",
      "echo 'Version ${var.chef_versions["client"]} of chef-client installed'",

      "echo Preparing directories",
      "sudo rm -rf /var/chef/cookbooks ; sudo mkdir -p /var/chef/cookbooks",
      "sudo rm -rf /var/chef/cache     ; sudo mkdir -p /var/chef/cache",
      "sudo rm -rf /var/chef/ssl       ; sudo mkdir -p /var/chef/ssl",

      "echo Downloading cookbooks",
      "echo 'for DEP in  <some var list> ; do curl -sL https://supermarket.chef.io/cookbooks/$ { DEP}/download | sudo tar xzC /var/chef/cookbooks; done'"
    ]
  }


  # Put certificate key
  provisioner "file" {
    source         = "${var.chef_ssl["key"]}"
    destination    = ".chef/${var.instance["hostname"]}.${var.instance["domain"]}.key"
  }
  # Put certificate
  provisioner "file" {
    source         = "${var.chef_ssl["cert"]}"
    destination    = ".chef/${var.instance["hostname"]}.${var.instance["domain"]}.pem"
  }
  # Write .chef/dna.json for chef-solo run
  provisioner "file" {
    content        = "${data.template_file.attributes-json.rendered}"
    destination    = ".chef/dna.json"
  }
  # Move certs
  provisioner "remote-exec" {
    inline = [
      "sudo mv .chef/${var.instance["hostname"]}.${var.instance["domain"]}.* /var/chef/ssl/"
    ]
  }
  # Run chef-solo and get us a Chef server
  provisioner "remote-exec" {
    inline = [
      "sudo chef-solo -j .chef/dna.json -o 'recipe[system::default],recipe[chef-server::default],recipe[chef-server::addons]'",
    ]
  }
  # Create first user and org
  provisioner "remote-exec" {
    inline = [
      "sudo chef-server-ctl user-create ${var.chef_user["username"]} ${var.chef_user["first"]} ${var.chef_user["last"]} ${var.chef_user["email"]} ${base64sha256(self.id)} -f .chef/${var.chef_user["username"]}.pem",
      "sudo chef-server-ctl org-create ${var.chef_org["short"]} '${var.chef_org["long"]}' --association_user ${var.chef_user["username"]} --filename .chef/${var.chef_org["short"]}-validator.pem",
    ]
  }
  # Correct ownership on .chef so we can harvest files
  provisioner "remote-exec" {
    inline = [
      "sudo chown -R ${local.user} .chef"
    ]
  }
  # Copy back .chef files
  provisioner "local-exec" {
    command = "scp -r -o stricthostkeychecking=no -i ${local.key_file_private} ${local.user}@${local.public_ip}:.chef/* .chef/"
  }
  # Replace local .chef/user.pem file with generated one
  provisioner "local-exec" {
    command = "cp -f .chef/${var.chef_user["username"]}.pem .chef/user.pem"
  }
  # Generate knife.rb
  provisioner "local-exec" {
    command = <<-EOC
      [ -f .chef/knife.rb ] && rm -f .chef/knife.rb
      cat > .chef/knife.rb <<EOF
      ${data.template_file.knife-rb.rendered}
      EOF
      EOC
  }
  # Upload knife.rb
  provisioner "file" {
    content        = "${data.template_file.knife-rb.rendered}"
    destination    = ".chef/knife.rb"
  }
  # Push in cookbooks
  provisioner "remote-exec" {
    inline = [
      "sudo knife cookbook upload -a -c .chef/knife.rb --cookbook-path /var/chef/cookbooks",
      "sudo rm -rf /var/chef/cookbooks",
    ]
  }

  # Provision with Chef
  provisioner "chef" {
    attributes_json = "${data.template_file.attributes-json.rendered}"
    environment     = "_default"
    log_to_file     = "${var.chef_log}"
    node_name       = "${local.public_dns}"
    run_list        = ["recipe[system::default]","recipe[chef-client::default]","recipe[chef-client::config]","recipe[chef-client::cron]","recipe[chef-client::delete_validation]","recipe[chef-server::default]","recipe[chef-server::addons]"]
    server_url      = "https://${local.public_dns}/organizations/${var.chef_org["short"]}"
    skip_install    = true
    user_name       = "${var.chef_user["username"]}"
    user_key        = "${file(".chef/user.pem")}"
  }
}


# Generate pretty output format
data "template_file" "chef-server-creds" {
  template = "${file("${path.module}/files/chef-server-creds.tpl")}"
  vars {
    user   = "${var.chef_user["username"]}"
    pass   = "${base64sha256(join(",", module.chef-server.id))}"
    user_p = ".chef/${var.chef_user["username"]}.pem"
    fqdn   = "${local.public_dns}"
    org    = "${var.chef_org["short"]}"
  }
}
# Write generated template file
resource "null_resource" "write-files" {
  provisioner "local-exec" {
    command = <<-EOC
      [ -f .chef/chef-server.creds ] && rm -f .chef/chef-server.creds
      cat > .chef/chef-server.creds <<EOF
      ${data.template_file.chef-server-creds.rendered}
      EOF
      EOC
  }
}
