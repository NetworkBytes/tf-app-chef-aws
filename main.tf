

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
      
      echo "** Gererate encrypted_data_bag_secret"
      rm -f .chef/encrypted_data_bag_secret
      openssl rand -base64 512 | tr -d '\r\n' > .chef/encrypted_data_bag_secret

      echo "** Generating ssl certificate"
      openssl req -x509 -newkey rsa:4096 \
        -keyout .chef/${var.instance["hostname"]}.${var.instance["domain"]}.key \
        -out .chef/${var.instance["hostname"]}.${var.instance["domain"]}.pem \
        -days 1000 -nodes -subj "/CN=${var.instance["hostname"]}.${var.instance["domain"]}"

    EOF
  }


  provisioner "remote-exec" {
    inline          = "[[ -d .chef ]] || mkdir -p .chef; echo Created .chef directory"
  }


  ## Put certificate key
  provisioner "file" {
    source         = "${local.chef_ssl_private_key}"
    destination    = ".chef/${var.instance["hostname"]}.${var.instance["domain"]}.key"
  }
  # Put certificate
  provisioner "file" {
    source         = "${local.chef_ssl_cert}"
    destination    = ".chef/${var.instance["hostname"]}.${var.instance["domain"]}.pem"
  }
  # Upload Attributes file .chef/dna.json for the chef-solo run
  provisioner "file" {
    content        = "${data.template_file.attributes-json.rendered}"
    destination    = ".chef/dna.json"
  }

  # install and configure
  provisioner "remote-exec" {
    inline = <<-EOF
      set -e

      #TODO centos aws image doesnt have any FW enabled
      #echo ** Disabling firewall
      #sudo systemctl disable firewalld
      #sudo systemctl stop firewalld


      echo "** Installing Chef client version ${var.chef_versions["client"]}"
      curl -L https://omnitruck.chef.io/install.sh | sudo bash -s -- -v ${var.chef_versions["client"]}
      #curl -L https://omnitruck.chef.io/install.sh | sudo bash

      echo "** Preparing directories"
      for DIR in cookbooks cache ssl; do sudo rm -rf /var/chef/$DIR; sudo mkdir -vp /var/chef/$DIR; done

      echo "** Copying certs /${var.instance["hostname"]}.${var.instance["domain"]} to /var/chef/ssl"
      sudo cp -f .chef/${var.instance["hostname"]}.${var.instance["domain"]}.* /var/chef/ssl/

      echo "** Downloading cookbooks"
      for DEP in chef-client chef-server chef-ingredient; do 
        echo "   - downloading cookbook $DEP" 
        curl -sL https://supermarket.chef.io/cookbooks/$DEP/download | sudo tar --warning=no-unknown-keyword -xzC /var/chef/cookbooks;
      done

      echo "** Running chef-solo to install Chef server"
      #sudo chef-solo -j .chef/dna.json -o 'recipe[system::default],recipe[chef-server::default],recipe[chef-server::addons]'
      sudo chef-solo -j ~${local.user}/.chef/dna.json


      echo "** Creating Chef user and org"
      sudo chef-server-ctl org-list  |grep -q ${var.chef_org["short"]}     && sudo chef-server-ctl org-delete  ${var.chef_org["short"]} -y
      sudo chef-server-ctl user-list |grep -q ${var.chef_user["username"]} && sudo chef-server-ctl user-delete ${var.chef_user["username"]} -y
      sudo chef-server-ctl user-create ${var.chef_user["username"]} ${var.chef_user["first"]} ${var.chef_user["last"]} ${var.chef_user["email"]} ${base64sha256(self.id)} -f .chef/${var.chef_user["username"]}.pem
      sudo chef-server-ctl org-create ${var.chef_org["short"]} '${var.chef_org["long"]}' --association_user ${var.chef_user["username"]} --filename .chef/${var.chef_org["short"]}-validator.pem

      echo "** Correct ownership on .chef so we can scp the files"
      sudo chown -R ${local.user} .chef
  
      echo "** Berkshelf Gem"
      sudo yum install -y gcc
      sudo /opt/chef/embedded/bin/gem install berkshelf 
    EOF
  }



  # Copy things back to local
  provisioner "local-exec" {
    command = <<-EOF
      set -e

      echo "** Copy .chef files to local terraform directory"
      scp -r -o stricthostkeychecking=no -i ${local.key_file_private} ${local.user}@${local.public_ip}:.chef/* .chef/
  
      echo "** Replace local .chef/user.pem file with generated one"
      cp -f .chef/${var.chef_user["username"]}.pem .chef/user.pem

      echo "** Generate knife.rb"
cat > .chef/knife.rb <<-EOK
${data.template_file.knife-rb.rendered}
EOK

echo  Write generated template file
cat > .chef/chef-server.creds <<-EOC
${data.template_file.chef-server-creds.rendered}
EOC

    EOF
  }

  # Upload knife.rb to chef server
  provisioner "file" {
    source      = ".chef/knife.rb"
    destination = ".chef/knife.rb"
  }


  provisioner "remote-exec" {
    inline = <<-EOF
      set -e
      echo "** Fetching the ssl cert from the server"
      knife ssl fetch 

      echo "** Uploading cookbooks into the Chef Server"
      sudo knife cookbook upload -a -c .chef/knife.rb --cookbook-path /var/chef/cookbooks
      sudo rm -rf /var/chef/cookbooks

      EOF
  }

  # Provision with Chef
  provisioner "chef" {
    attributes_json = "${data.template_file.attributes-json.rendered}"
    environment     = "_default"
    log_to_file     = "${var.chef_log}"
    node_name       = "${local.public_dns}"
    run_list        = ["recipe[chef-client::default]"] #,"recipe[system::default]","recipe[chef-client::config]","recipe[chef-client::cron]","recipe[chef-client::delete_validation]","recipe[chef-server::default]","recipe[chef-server::addons]"]
    server_url      = "https://${local.public_dns}/organizations/${var.chef_org["short"]}"
    skip_install    = true
    user_name       = "${var.chef_user["username"]}"
    user_key        = "${file(".chef/user.pem")}"
  }
}
