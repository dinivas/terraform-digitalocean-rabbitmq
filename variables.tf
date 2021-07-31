variable "enable_rabbitmq" {
  type    = string
  default = "1"
}

variable "project_name" {
  description = "The project this RabbitMQ cluster belong to"
  type        = string
}

variable "rabbitmq_cluster_name" {
  description = "The name of the RabbitMQ cluster"
  type        = string
}

variable "rabbitmq_cluster_erlang_cookie" {
  description = "The Erlang cookie to use for clustering"
  type        = string
  default     = ""
}

variable "rabbitmq_cluster_image_name" {
  description = "The Image name of the Rabbitmq nodes"
  type        = string
}

variable "rabbitmq_cluster_compute_flavor_name" {
  description = "The Flavor name of the Rabbitmq node"
  type        = string
}

variable "rabbitmq_cluster_keypair_name" {
  description = "The Keypair name of the RabbitMQ node."
  type        = string
}

variable "rabbitmq_nodes_count" {
  type        = string
  description = "The number of RabbitMQ nodes."
}

variable "rabbitmq_plugin_list" {
  type        = string
  description = "The list of plugins to enable (separated by ,)"
  default     = "rabbitmq_prometheus,rabbitmq_management_agent,rabbitmq_management,rabbitmq_peer_discovery_consul"
}

variable "rabbitmq_cluster_availability_zone" {
  description = "The availability zone"
  type        = string
  default     = "null"
}

variable "rabbitmq_cluster_network" {
  description = "The Network name of the cluster"
  type        = string
}

variable "rabbitmq_cluster_security_group_rules" {
  type        = list(map(any))
  default     = []
  description = "The definition os security groups to associate to instance. Only one is allowed"
}

variable "rabbitmq_cluster_security_groups_to_associate" {
  type        = list(string)
  default     = []
  description = "List of existing security groups to associate to RabbitMQ nodes."
}

variable "rabbitmq_cluster_metadata" {
  default = {}
}

variable "rabbitmq_enable_logging_graylog" {
  type = number
  description = "Should graylog output be enable on this host"
  default = 0
}

# Project Consul variables

variable "project_consul_domain" {
  type        = string
  description = "The domain name to use for the Consul cluster"
}

variable "project_consul_datacenter" {
  type        = string
  description = "The datacenter name for the consul cluster"
}

variable "do_api_token" {
  type = string
}

variable "generic_user_data_file_url" {
  type    = string
  default = "https://raw.githubusercontent.com/dinivas/terraform-shared/master/templates/generic-user-data.tpl"
}

variable "execute_on_destroy_rabbitmq_node_script" {
  type    = string
  default = "consul leave"
}

variable "ssh_via_bastion_config" {
  description = "config map used to connect via bastion ssh"
  default     = {}
}
