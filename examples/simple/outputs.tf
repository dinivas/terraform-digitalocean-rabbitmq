output "rabbitmq_cluster_instance_ids" {
  value = "${module.rabbitmq_cluster.rabbitmq_cluster_instance_ids}"
}

output "rabbitmq_cluster_network_fixed_ip_v4" {
  value = "${module.rabbitmq_cluster.rabbitmq_cluster_network_fixed_ip_v4}"
}
