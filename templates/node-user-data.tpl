-   content: |
        {"service":
            {"name": "${rabbitmq_cluster_name}-dashboard",
            "tags": ["web"],
            "port": 15672
            }
        }

    owner: consul:bin
    path: /etc/consul/consul.d/rabbitmq-dashboard-service.json
    permissions: '644'
-   content: |
        {"service":
            {"name": "${rabbitmq_cluster_name}-exporter",
            "tags": ["monitor"],
            "port": 15692
            }
        }

    owner: consul:bin
    path: /etc/consul/consul.d/rabbitmq-exporter-service.json
    permissions: '644'
-   content: |
        [${rabbitmq_plugin_list}].

    owner: rabbitmq:rabbitmq
    path: /etc/rabbitmq/enabled_plugins
    permissions: '644'
-   content: |
        listeners.tcp.default = 5672
        num_acceptors.tcp = 10
        log.file.level = info
        default_vhost = ${rabbitmq_cluster_name}
        default_user = ${rabbitmq_cluster_default_username}
        default_pass = ${rabbitmq_cluster_default_password}
        default_user_tags.administrator = true
        loopback_users = none
        auth_mechanisms.1 = PLAIN
        auth_mechanisms.2 = AMQPLAIN
        auth_backends.1 = internal
        queue_master_locator = client-local
        management.cors.allow_origins.1 = *
        cluster_formation.peer_discovery_backend = rabbit_peer_discovery_consul
        cluster_formation.consul.host = localhost
        cluster_formation.consul.svc = ${rabbitmq_cluster_name}
        cluster_formation.node_cleanup.only_log_warning = false
        cluster_formation.consul.deregister_after = 90

    owner: rabbitmq:rabbitmq
    path: /etc/rabbitmq/rabbitmq.conf
    permissions: '644'
-   content: |
        ${rabbitmq_cluster_erlang_cookie}

    owner: rabbitmq:rabbitmq
    path: /var/lib/rabbitmq/.erlang.cookie
    permissions: '400'