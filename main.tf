data "digitalocean_vpc" "rabbitmq_cluster_network" {
  count = var.enable_rabbitmq

  name = var.rabbitmq_cluster_network
}

data "digitalocean_ssh_key" "rabbitmq_cluster" {
  count = var.enable_rabbitmq

  name = "${var.project_name}-project-keypair"
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
  rabbitmq_cluster_computed_erlang_cookie = var.rabbitmq_cluster_erlang_cookie != "" ? var.rabbitmq_cluster_erlang_cookie : random_string.random_erlang_cookie.result
}

data "http" "generic_user_data_template" {
  url = var.generic_user_data_file_url
}


data "template_file" "rabbitmq_node_user_data" {
  count = var.rabbitmq_nodes_count * var.enable_rabbitmq

  template = data.http.generic_user_data_template.body

  vars = {
    cloud_provider            = "digitalocean"
    project_name              = var.project_name
    consul_agent_mode         = "client"
    consul_cluster_domain     = var.project_consul_domain
    consul_cluster_datacenter = var.project_consul_datacenter
    consul_cluster_name       = "${var.project_name}-consul"
    do_region                 = var.rabbitmq_cluster_availability_zone
    do_api_token              = var.do_api_token
    enable_logging_graylog    = var.rabbitmq_enable_logging_graylog

    pre_configure_script     = ""
    custom_write_files_block = "${lookup(data.template_file.rabbitmq_node_custom_user_data[count.index], "rendered")}"
    post_configure_script    = <<-EOT
      systemctl enable rabbitmq-server
      systemctl start rabbitmq-server
    EOT
  }
}

data "template_file" "rabbitmq_node_custom_user_data" {
  count = var.rabbitmq_nodes_count * var.enable_rabbitmq

  template = file("${path.module}/templates/node-user-data.tpl")

  vars = {
    project_name                      = var.project_name
    rabbitmq_cluster_name             = var.rabbitmq_cluster_name
    rabbitmq_cluster_default_username = random_string.random_default_username.result
    rabbitmq_cluster_default_password = random_string.random_default_password.result
    rabbitmq_cluster_default_vhost    = var.rabbitmq_cluster_name
    rabbitmq_cluster_erlang_cookie    = local.rabbitmq_cluster_computed_erlang_cookie
    rabbitmq_plugin_list              = var.rabbitmq_plugin_list
  }
}

resource "digitalocean_droplet" "rabbitmq_instance" {
  count = var.rabbitmq_nodes_count * var.enable_rabbitmq

  name               = format("%s-%s-%s", var.project_name, var.rabbitmq_cluster_name, count.index)
  image              = var.rabbitmq_cluster_image_name
  size               = var.rabbitmq_cluster_compute_flavor_name
  ssh_keys           = [data.digitalocean_ssh_key.rabbitmq_cluster.0.id]
  region             = var.rabbitmq_cluster_availability_zone
  vpc_uuid           = data.digitalocean_vpc.rabbitmq_cluster_network.0.id
  user_data          = data.template_file.rabbitmq_node_user_data.0.rendered
  tags               = concat([var.project_name], split(",", format("consul_cluster_name_%s-%s,project_%s", var.project_name, "consul", var.project_name)))
  private_networking = true
}

resource "null_resource" "rabbitmq_consul_client_leave" {
  count = var.rabbitmq_nodes_count * var.enable_rabbitmq

  triggers = {
    private_ip                              = digitalocean_droplet.rabbitmq_instance[count.index].ipv4_address_private
    host_private_key                        = lookup(var.ssh_via_bastion_config, "host_private_key")
    bastion_host                            = lookup(var.ssh_via_bastion_config, "bastion_host")
    bastion_port                            = lookup(var.ssh_via_bastion_config, "bastion_port")
    bastion_ssh_user                        = lookup(var.ssh_via_bastion_config, "bastion_ssh_user")
    bastion_private_key                     = lookup(var.ssh_via_bastion_config, "bastion_private_key")
    execute_on_destroy_rabbitmq_node_script = var.execute_on_destroy_rabbitmq_node_script
  }

  connection {
    type        = "ssh"
    user        = "root"
    port        = 22
    host        = self.triggers.private_ip
    private_key = self.triggers.host_private_key
    agent       = false

    bastion_host        = self.triggers.bastion_host
    bastion_port        = self.triggers.bastion_port
    bastion_user        = self.triggers.bastion_ssh_user
    bastion_private_key = self.triggers.bastion_private_key
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      self.triggers.execute_on_destroy_rabbitmq_node_script
    ]
    on_failure = continue
  }

}
