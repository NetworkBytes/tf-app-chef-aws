###################################
## User Data Config script
###################################
data "template_file" "user_data" {
    template = "${file("${path.module}/files/cloud-init_chef-server.tpl")}"
    vars {
        #cm_hostname     = "${local.cm_hostname}"
    }
}
