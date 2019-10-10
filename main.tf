data "openstack_networking_network_v2" "rabbitmq_cluster_network" {
  count = "${var.enable_rabbitmq}"

  name = "${var.rabbitmq_cluster_network}"
}

data "openstack_networking_subnet_v2" "rabbitmq_cluster_subnet" {
  count = "${var.enable_rabbitmq}"

  name = "${var.rabbitmq_cluster_subnet}"
}


data "template_file" "rabbitmq_node_user_data" {
  count = "${var.rabbitmq_nodes_count}"

  template = "${file("${path.module}/templates/user-data.tpl")}"

  vars = {
    project_name              = "${var.project_name}"
    rabbitmq_cluster_name     = "${var.rabbitmq_cluster_name}"
    rabbitmq_plugin_list      = "${var.rabbitmq_plugin_list}"
    consul_agent_mode         = "client"
    consul_cluster_domain     = "${var.project_consul_domain}"
    consul_cluster_datacenter = "${var.project_consul_datacenter}"
    consul_cluster_name       = "${var.project_name}-consul"
    os_auth_domain_name       = "${var.os_auth_domain_name}"
    os_auth_username          = "${var.os_auth_username}"
    os_auth_password          = "${var.os_auth_password}"
    os_auth_url               = "${var.os_auth_url}"
    os_project_id             = "${var.os_project_id}"
  }
}

module "rabbitmq_node_instance" {
  source = "github.com/dinivas/terraform-openstack-instance"

  instance_name                 = "${var.rabbitmq_cluster_name}"
  instance_count                = "${var.rabbitmq_nodes_count}"
  image_name                    = "${var.rabbitmq_cluster_image_name}"
  flavor_name                   = "${var.rabbitmq_cluster_compute_flavor_name}"
  keypair                       = "${var.rabbitmq_cluster_keypair_name}"
  network_ids                   = ["${data.openstack_networking_network_v2.rabbitmq_cluster_network.0.id}"]
  subnet_ids                    = ["${data.openstack_networking_subnet_v2.rabbitmq_cluster_subnet.*.id}"]
  instance_security_group_name  = "${var.rabbitmq_cluster_name}-sg"
  instance_security_group_rules = "${var.rabbitmq_cluster_security_group_rules}"
  security_groups_to_associate  = "${var.rabbitmq_cluster_security_groups_to_associate}"
  user_data                     = "${data.template_file.rabbitmq_node_user_data.0.rendered}"
  metadata                      = "${merge(var.rabbitmq_cluster_metadata, map("consul_cluster_name", format("%s-%s", var.project_name, "consul")))}"
  enabled                       = "${var.enable_rabbitmq}"
  availability_zone             = "${var.rabbitmq_cluster_availability_zone}"

}
