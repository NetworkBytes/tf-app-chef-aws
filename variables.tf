
#
# specific configs
#
variable "allowed_cidrs" {
  type             = "string"
  description      = "List of CIDRs to allow SSH from (CSV list allowed)"
  default          = "0.0.0.0/0"
}
variable "chef_addons" {
  type             = "string"
  description      = "Comma seperated list of addons to install. Default: `manage,push-jobs-server,reporting`"
  default          = "manage,push-jobs-server,reporting"
}
variable "chef_license" {
  type             = "string"
  description      = "Acceptance of the Chef MLSA: https://www.chef.io/online-master-agreement/"
  default          = "true"
}
variable "chef_log" {
  #type             = "boolean"
  description      = "Log chef provisioner to file"
  default          = "true"
}
variable "chef_org" {
  type             = "map"
  description      = "Chef organization settings"
  default          = {
    long           = "Chef Organization"
    short          = "chef"
  }
}
variable "chef_ssl" {
  type             = "map"
  description      = "Chef server SSL settings"
  default          = {
    cert           = ""
    key            = ""
  }
}
variable "chef_user" {
  type             = "map"
  description      = "Chef user settings"
  default          = {
    email          = "chef.admin@domain.tld"
    first          = "Chef"
    last           = "Admin"
    username       = "chefadmin"
  }
}
variable "chef_versions" {
  type             = "map"
  description      = "Chef software versions"
  default          = {
    client         = ""
    server         = ""
  }
}
variable "instance" {
  type             = "map"
  description      = "EC2 instance host settings"
  default          = {
    domain         = "localdomain"
    hostname       = "localhost"
  }
}
variable "instance_flavor" {
  type             = "string"
  description      = "EC2 instance flavor (type). Default: c3.xlarge"
  default          = "c3.xlarge"
}

