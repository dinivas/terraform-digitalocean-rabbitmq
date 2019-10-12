data "openstack_networking_network_v2" "rabbitmq_cluster_network" {
  count = "${var.enable_rabbitmq}"

  name = "${var.rabbitmq_cluster_network}"
}

data "openstack_networking_subnet_v2" "rabbitmq_cluster_subnet" {
  count = "${var.enable_rabbitmq}"

  name = "${var.rabbitmq_cluster_subnet}"
}

resource "random_string" "random_erlang_cookie" {
  length  = 48
  special = false
}

resource "random_string" "random_default_username" {
  length  = 8
  special = false
}

resource "random_string" "random_default_password" {
  length  = 32
  special = false
}

locals {
  rabbitmq_cluster_computed_erlang_cookie = "${var.rabbitmq_cluster_erlang_cookie != "" ? var.rabbitmq_cluster_erlang_cookie : random_string.random_erlang_cookie.result}"
}

data "http" "generic_user_data_template" {
  url = "${var.generic_user_data_file_url}"
}


data "template_file" "rabbitmq_node_user_data" {
  count = "${var.rabbitmq_nodes_count}"

  template = "${data.http.generic_user_data_template.body}"

  vars = {
    consul_agent_mode         = "client"
    consul_cluster_domain     = "${var.project_consul_domain}"
    consul_cluster_datacenter = "${var.project_consul_datacenter}"
    consul_cluster_name       = "${var.project_name}-consul"
    os_auth_domain_name       = "${var.os_auth_domain_name}"
    os_auth_username          = "${var.os_auth_username}"
    os_auth_password          = "${var.os_auth_password}"
    os_auth_url               = "${var.os_auth_url}"
    os_project_id             = "${var.os_project_id}"

    pre_configure_script     = ""
    custom_write_files_block = "${data.template_file.rabbitmq_node_custom_user_data.0.rendered}"
    post_configure_script    = <<-EOT
      systemctl enable rabbitmq-server
      systemctl start rabbitmq-server
    EOT
  }
}

data "template_file" "rabbitmq_node_custom_user_data" {
  count = "${var.rabbitmq_nodes_count}"

  template = "${file("${path.module}/templates/node-user-data.tpl")}"

  vars = {
    project_name = "${var.project_name}"
    rabbitmq_cluster_name = "${var.rabbitmq_cluster_name}"
    rabbitmq_cluster_default_username = "${random_string.random_default_username.result}"
    rabbitmq_cluster_default_password = "${random_string.random_default_password.result}"
    rabbitmq_cluster_default_vhost = "${var.rabbitmq_cluster_name}"
    rabbitmq_cluster_erlang_cookie = "${local.rabbitmq_cluster_computed_erlang_cookie}"
    rabbitmq_plugin_list = "${var.rabbitmq_plugin_list}"
  }
}

module "rabbitmq_node_instance" {
  source = "github.com/dinivas/terraform-openstack-instance"

  instance_name = "${var.rabbitmq_cluster_name}"
  instance_count = "${var.rabbitmq_nodes_count}"
  image_name = "${var.rabbitmq_cluster_image_name}"
  flavor_name = "${var.rabbitmq_cluster_compute_flavor_name}"
  keypair = "${var.rabbitmq_cluster_keypair_name}"
  network_ids = ["${data.openstack_networking_network_v2.rabbitmq_cluster_network.0.id}"]
  subnet_ids = ["${data.openstack_networking_subnet_v2.rabbitmq_cluster_subnet.*.id}"]
  instance_security_group_name = "${var.rabbitmq_cluster_name}-sg"
  instance_security_group_rules = "${var.rabbitmq_cluster_security_group_rules}"
  security_groups_to_associate = "${var.rabbitmq_cluster_security_groups_to_associate}"
  user_data = "${data.template_file.rabbitmq_node_user_data.0.rendered}"
  metadata = "${merge(var.rabbitmq_cluster_metadata, map("consul_cluster_name", format("%s-%s", var.project_name, "consul")))}"
  enabled = "${var.enable_rabbitmq}"
  availability_zone = "${var.rabbitmq_cluster_availability_zone}"

}
