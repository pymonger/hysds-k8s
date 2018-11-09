# globals
variable "tenant_name" {}

variable "tenant_id" {}

variable "user_name" {}

variable "password" {}

variable "key_pair" {}

variable "network_name" {}

variable "network_id" {}

variable "security_group" {}

variable "count" {}

variable "auth_url" {
  default = "https://iu.jetstream-cloud.org:5000/v3"
}

variable "region" {
  default = "RegionOne"
}

variable "pool" {
  default = "public"
}

variable "kube-node" {
  type = "map"
  default = {
    image_id = "3b301ac5-75f5-4ecd-9bef-ea56572accc5"
    flavor_id = "3"
    data_size = 100
  }
}
