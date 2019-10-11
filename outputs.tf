output "rabbitmq_cluster_instance_ids" {
  value = "${module.rabbitmq_node_instance.ids}"
}

output "rabbitmq_cluster_network_fixed_ip_v4" {
  value = "${module.rabbitmq_node_instance.network_fixed_ip_v4}"
}

output "rabbitmq_cluster_default_username" {
  value = "${random_string.random_default_username.result}"
}

output "rabbitmq_cluster_default_password" {
  value = "${random_string.random_default_password.result}"
}

output "rabbitmq_cluster_default_vhost" {
  value = "${var.rabbitmq_cluster_name}"
}

