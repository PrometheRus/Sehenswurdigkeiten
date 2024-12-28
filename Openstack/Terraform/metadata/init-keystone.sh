#!/bin/bash

sudo yum -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
sudo percona-release setup ps-80
sudo yum -y install percona-server-server
