#!/bin/bash

sudo apt-get update
sudo apt-get install -y wget gnupg2 lsb-release curl
curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb
sudo apt-get install -y ./percona-release_latest.generic_all.deb
sudo apt-get update
sudo percona-release setup pxc80
sudo apt-get install mysql-client-core-8.0
# sudo apt-get install -y percona-xtradb-cluster