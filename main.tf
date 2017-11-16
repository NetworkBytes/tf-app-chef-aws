

module "chef-server" {
  source = "github.com/NetworkBytes/tf-module-aws-vm"
  config = "${local.config}"
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


  provisioner "local-exec" {
    command = <<-EOF
      set -e

      echo "Gererate encrypted_data_bag_secret"
      rm -f .chef/encrypted_data_bag_secret
      openssl rand -base64 512 | tr -d '\r\n' > .chef/encrypted_data_bag_secret

      echo "Gererate Chef Server Keys"
      # TODO make this work
      #rm -f .chef/server.{pem,pub} 
      #ssh-keygen -b 2048 -t rsa -f .chef/server -q -N '' -C 'chef_server_key'
      

      EOF
  }
  ## Put certificate key
  #provisioner "file" {
  #  source         = "${var.chef_ssl["key"]}"
  #  destination    = ".chef/${var.instance["hostname"]}.${var.instance["domain"]}.key"
  #}
  # Put certificate
  #provisioner "file" {
  #  source         = "${var.chef_ssl["cert"]}"
  #  destination    = ".chef/${var.instance["hostname"]}.${var.instance["domain"]}.pem"
  #}
  # Upload Attributes file .chef/dna.json for the chef-solo run
  provisioner "file" {
    content        = "${data.template_file.attributes-json.rendered}"
    destination    = "/home/${locals.user}/.chef/dna.json"
  }
  # Move certs
  #provisioner "remote-exec" {
  #  inline = [
  #    "sudo mv .chef/${var.instance["hostname"]}.${var.instance["domain"]}.* /var/chef/ssl/"
  #  ]
  #}
  provisioner "remote-exec" {
    inline = <<-EOF
      set -e

      #TODO centos aws image doesnt have any FW enabled
      #echo Disabling firewall
      #sudo systemctl disable firewalld
      #sudo systemctl stop firewalld

      [[ -d .chef ]] || sudo mkdir -p .chef
      #curl -L https://omnitruck.chef.io/install.sh | sudo bash -s -- -v ${var.chef_versions["client"]}
      curl -L https://omnitruck.chef.io/install.sh | sudo bash

      echo 'Version ${var.chef_versions["client"]} of chef-client installed'

      echo Preparing directories
      sudo rm -rf /var/chef/cookbooks ; sudo mkdir -p /var/chef/cookbooks
      sudo rm -rf /var/chef/cache     ; sudo mkdir -p /var/chef/cache
      sudo rm -rf /var/chef/ssl       ; sudo mkdir -p /var/chef/ssl

      echo Downloading cookbooks
      for DEP in chef-client chef-server chef-ingredient; do curl -sL https://supermarket.chef.io/cookbooks/$DEP/download | sudo tar xzC /var/chef/cookbooks; done
      #sudo chef-solo -j .chef/dna.json -o 'recipe[system::default],recipe[chef-server::default],recipe[chef-server::addons]'
      sudo chef-solo -j .chef/dna.json -o 'recipe[system::default],recipe[chef-server::default],recipe[chef-server::addons]'

      echo Running chef-solo to install Chef server
      sudo chef-solo -j .chef/dna.json -o 'recipe[system::default],recipe[chef-server::default],recipe[chef-server::addons]'

      echo Creating Chef user and org
      sudo chef-server-ctl user-create ${var.chef_user["username"]} ${var.chef_user["first"]} ${var.chef_user["last"]} ${var.chef_user["email"]} ${base64sha256(self.id)} -f .chef/${var.chef_user["username"]}.pem
      sudo chef-server-ctl org-create ${var.chef_org["short"]} '${var.chef_org["long"]}' --association_user ${var.chef_user["username"]} --filename .chef/${var.chef_org["short"]}-validator.pem

      echo Correct ownership on .chef so we can scp the files
      sudo chown -R ${local.user} .chef
  
    EOF
  }



  
  provisioner "local-exec" {
    command = <<-EOF
      set -e

      echo Copy .chef files to local terraform directory
      scp -r -o stricthostkeychecking=no -i ${local.key_file_private} ${local.user}@${local.public_ip}:.chef/* .chef/
  
      echo Replace local .chef/user.pem file with generated one
      cp -f .chef/${var.chef_user["username"]}.pem .chef/user.pem

      echo Generate knife.rb
      cat > .chef/knife.rb <<EOK
      ${data.template_file.knife-rb.rendered}
      EOK

      echo  Write generated template file
      cat > .chef/chef-server.creds <<EOC
      ${data.template_file.chef-server-creds.rendered}
      EOC

    EOF
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
