#!/bin/bash



tee -a /etc/mysql/mariadb.conf.d/70-custom.cnf > /dev/null <<EOF

# Setup custom cluster
[mariadb]
binlog_format=row
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
wsrep_on=ON
wsrep_cluster_name="my_galera_cluster"
wsrep_cluster_address="gcomm://192.168.199.212,192.168.199.165,192.168.199.66"
wsrep_node_address="gcomm://192.168.199.212"
wsrep_node_name="node1"  # Change to node2, node3, etc.
wsrep_provider = /usr/lib/libgalera_smm.so
EOF


CREATE USER 'sst_user'@'%' IDENTIFIED BY 'sst_password';
GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO 'sst_user'@'%';
FLUSH PRIVILEGES;


wsrep_cluster_address="gcomm://192.168.199.210,192.168.199.27,192.168.199.213"
wsrep_node_address="gcomm://192.168.199.210"
wsrep_node_name="node1"  # Change to node2, node3, etc.
wsrep_sst_method=rsync
wsrep_provider = /usr/lib/libgalera_smm.so