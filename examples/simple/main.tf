variable "project_keycloak_host" {}
variable "do_api_token" {}
variable "ssh_via_bastion_config" {}

module "rabbitmq_cluster" {
  source = "../../"

  project_name                                  = "dnv"
  enable_rabbitmq                               = "1"
  rabbitmq_cluster_name                         = "rabbitmq"
  rabbitmq_nodes_count                          = 2
  rabbitmq_cluster_image_name                   = 88922052
  rabbitmq_cluster_compute_flavor_name          = "s-1vcpu-2gb-intel"
  rabbitmq_cluster_keypair_name                 = "dnv-project-keypair"
  rabbitmq_cluster_network                      = "dnv-mgmt"
  rabbitmq_cluster_security_groups_to_associate = ["dnv-common"]
  rabbitmq_cluster_availability_zone            = "fra1"
  rabbitmq_plugin_list                          = "rabbitmq_prometheus,rabbitmq_management_agent,rabbitmq_management,rabbitmq_peer_discovery_consul"
  rabbitmq_enable_logging_graylog               = "1"

  project_consul_domain     = "dinivas.io"
  project_consul_datacenter = "fra1"

  ssh_via_bastion_config = var.ssh_via_bastion_config
  do_api_token           = var.do_api_token
}
