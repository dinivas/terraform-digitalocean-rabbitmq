output "rabbitmq_cluster_default_username" {
  value = random_string.random_default_username.result
}

output "rabbitmq_cluster_default_password" {
  value = random_string.random_default_password.result
}

output "rabbitmq_cluster_default_vhost" {
  value = var.rabbitmq_cluster_name
}
output "rabbitmq_cluster_instance_ids" {
  value = digitalocean_droplet.rabbitmq_instance.*.id
}

output "rabbitmq_cluster_network_private_fixed_ip_v4" {
  value = digitalocean_droplet.rabbitmq_instance.*.ipv4_address_private
}
output "rabbitmq_cluster_network_public_fixed_ip_v4" {
  value = digitalocean_droplet.rabbitmq_instance.*.ipv4_address
}


