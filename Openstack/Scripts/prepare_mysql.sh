#!/bin/bash

### Действия выполняются руками, так как неудобно через IaC
# ROOT_PASS="DemoPassword134!"
mysql_config_editor -v set --user root --password


MYSQL_PASS="LnCK43Fxg8#"
# Mysql Keystone
mysql -e "CREATE DATABASE keystone; "
mysql -e "CREATE USER 'keystone'@'%' IDENTIFIED BY '${MYSQL_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%';"

# Mysql Neutron
mysql -e "CREATE DATABASE neutron;"
mysql -e "CREATE USER 'neutron'@'%' IDENTIFIED BY '${MYSQL_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%';"

# Mysql Octavia
mysql -e "CREATE DATABASE octavia;"
mysql -e "CREATE USER 'octavia'@'%' IDENTIFIED BY '${MYSQL_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON octavia.* TO 'octavia'@'%';"