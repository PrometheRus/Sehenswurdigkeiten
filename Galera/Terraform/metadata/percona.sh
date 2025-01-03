#!/bin/bash

timedatectl set-timezone Europe/Moscow
yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm
percona-release setup pxc-80
yum update -y && yum install -y percona-xtradb-cluster && systemctl start mysql

# Get root's password
mysql_password=$(grep 'temporary password' /var/log/mysqld.log | grep -oP ".{12}$")
tee /root/.my.cnf > /dev/null <<EOF
[client]
user=root
password=${mysql_password}
host=localhost
port=3306
EOF

# Fist connect to mysqld & Update password for root
new_mysql_password=$(openssl rand -hex 12)
chmod 600 /root/.my.cnf
mysql --defaults-file=/root/.my.cnf --connect-expired-password  -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${new_mysql_password}';" && \
tee /root/.my.cnf > /dev/null <<EOF
[client]
user=root
password=${new_mysql_password}
host=localhost
port=3306
EOF

if [ $? -eq 0 ] ; then
    echo "Command succeeded"
    systemctl stop mysql

    # Configure Percona
    ### wsrep_provider=/usr/lib64/galera4/libgalera_smm.so    # уже есть с конфиге, дополнительно не нужно добавлять
    sed -i "s/wsrep_cluster_name=pxc-cluster/wsrep_cluster_name=demo/" /etc/my.cnf
    sed -i "s/wsrep_cluster_address=gcomm:\/\//wsrep_cluster_address=gcomm:\/\/192.168.10.11,192.168.10.12,192.168.10.13/" /etc/my.cnf
    sed -i "s/wsrep_node_name=pxc-cluster-node-1/wsrep_node_name=$(hostnamectl hostname)/" /etc/my.cnf
    sed -i "s/#wsrep_node_address=192.168.70.63/wsrep_node_address=$(hostname -I)/" /etc/my.cnf

    grep -ni -e wsrep_cluster_name -e wsrep_cluster_address -e wsrep_node_name -e wsrep_node_address /etc/my.cnf
else
    echo "Command failed"
fi

tee -a /etc/my.cnf > /dev/null <<EOF

pxc-encrypt-cluster-traffic=OFF
EOF

sleep 180s;
systemctl start mysql