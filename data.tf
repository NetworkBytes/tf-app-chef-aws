
# Chef provisiong attributes_json and .chef/dna.json templating
data "template_file" "attributes-json" {
  template = "${file("${path.module}/files/attributes-json.tpl")}"
  vars {
    #addons  = "${join(",", list("\\"%s\\"", split(",", var.chef_addons)))}"
    addons  = "manage"
    domain  = "${var.instance["domain"]}"
    host    = "${var.instance["hostname"]}"
    license = "${var.chef_license}"
    version = "${var.chef_versions["server"]}"
  }
}

# knife.rb templating
data "template_file" "knife-rb" {
  template = "${file("${path.module}/files/knife-rb.tpl")}"
  vars {
    user   = "${var.chef_user["username"]}"
    fqdn   = "${var.instance["hostname"]}.${var.instance["domain"]}"
    org    = "${var.chef_org["short"]}"
  }
}