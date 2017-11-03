###################################
## User Data Config script
###################################
data "template_file" "user_data" {
    template = "${file("${path.module}/files/cloud-init_chef-server.tpl")}"
    vars {
        #cm_hostname     = "${local.cm_hostname}"
    }
}


# Chef provisiong attributes_json and .chef/dna.json templating
data "template_file" "attributes-json" {
  template = "${file("${path.module}/files/attributes-json.tpl")}"
  vars {
    addons  = "${join(",", formatlist("\\"%s\\"", split(",", var.chef_addons)))}"
    domain  = "${var.instance["domain"]}"
    host    = "${var.instance["hostname"]}"
    license = "${var.chef_license}"
    version = "${var.chef_versions["server"]}"
  }
}