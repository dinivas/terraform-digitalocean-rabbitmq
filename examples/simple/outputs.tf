output "rabbitmq_cluster_instance_ids" {
  value = module.rabbitmq_cluster.rabbitmq_cluster_instance_ids
}

output "rabbitmq_cluster_network_private_fixed_ip_v4" {
  value = module.rabbitmq_cluster.rabbitmq_cluster_network_private_fixed_ip_v4
}
output "rabbitmq_cluster_network_public_fixed_ip_v4" {
  value = module.rabbitmq_cluster.rabbitmq_cluster_network_public_fixed_ip_v4
}

output "rabbitmq_cluster_default_username" {
  value = module.rabbitmq_cluster.rabbitmq_cluster_default_username
}

output "rabbitmq_cluster_default_password" {
  value = module.rabbitmq_cluster.rabbitmq_cluster_default_password
}

output "rabbitmq_cluster_default_vhost" {
  value = module.rabbitmq_cluster.rabbitmq_cluster_default_vhost
}
