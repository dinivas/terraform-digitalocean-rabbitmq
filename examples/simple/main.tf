variable "os_auth_domain_name" {
  type    = "string"
  default = "default"
}

variable "os_auth_username" {}

variable "os_auth_password" {}

variable "os_auth_url" {}

variable "os_project_id" {}

module "rabbitmq_cluster" {
  source = "../../"

  project_name                                  = "dnv"
  enable_rabbitmq                               = "1"
  rabbitmq_cluster_name                         = "dnv-rabbitmq"
  rabbitmq_nodes_count                          = 2
  rabbitmq_cluster_image_name                   = "Dinivas RabbitMQ"
  rabbitmq_cluster_compute_flavor_name          = "dinivas.medium"
  rabbitmq_cluster_keypair_name                 = "dnv"
  rabbitmq_cluster_network                      = "dnv-mgmt"
  rabbitmq_cluster_subnet                       = "dnv-mgmt-subnet"
  rabbitmq_cluster_security_groups_to_associate = ["dnv-common"]
  rabbitmq_cluster_availability_zone            = "nova:node03"
  rabbitmq_plugin_list                          = "rabbitmq_prometheus,rabbitmq_management_agent,rabbitmq_management,rabbitmq_peer_discovery_consul"

  project_consul_domain     = "dinivas"
  project_consul_datacenter = "nova"

  os_auth_domain_name = "${var.os_auth_domain_name}"
  os_auth_username    = "${var.os_auth_username}"
  os_auth_password    = "${var.os_auth_password}"
  os_auth_url         = "${var.os_auth_url}"
  os_project_id       = "${var.os_project_id}"
}
