provider "openstack" {
  project_domain_id   = "${var.project_domain_id}"
  user_domain_name    = "${var.user_domain_name}"
  user_name           = "${var.user_name}"
  password            = "${var.password}"
  auth_url            = "${var.auth_url}"
  region              = "${var.region}"
}


######################
# nodes
######################

resource "openstack_compute_instance_v2" "kube-node" {
  count                  = "${var.count}"
  name                   = "kube-node-${count.index}"
  image_id               = "${var.kube-node["image_id"]}"
  flavor_id              = "${var.kube-node["flavor_id"]}"
  key_pair               = "${var.key_pair}"
  security_groups        = ["${var.security_group}"]

  network {
    uuid = "${var.network_id}"
    name = "${var.network_name}"
  }
}

resource "openstack_blockstorage_volume_v2" "kube-node_data" {
  count = "${var.count}"
  name = "kube-node_data-${count.index}"
  size = "${var.kube-node["data_size"]}"
}

resource "openstack_networking_floatingip_v2" "kube-node_ip" {
  count = "${var.count}"
  pool = "${var.pool}"
}

resource "openstack_compute_volume_attach_v2" "attached_kube-node_data" {
  instance_id = "${element(openstack_compute_instance_v2.kube-node.*.id, count.index)}"
  volume_id = "${element(openstack_blockstorage_volume_v2.kube-node_data.*.id, count.index)}"
}

resource "openstack_compute_floatingip_associate_v2" "kube-node_ip" {
  instance_id = "${element(openstack_compute_instance_v2.kube-node.*.id, count.index)}"
  floating_ip = "${element(openstack_networking_floatingip_v2.kube-node_ip.*.address, count.index)}"
}
