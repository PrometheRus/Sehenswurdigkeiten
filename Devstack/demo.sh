#!/bin/bash


=========================
DevStack Component Timing
 (times are in seconds)
=========================
wait_for_service      18
async_wait           866
osc                  481
apt-get               10
test_with_retry        9
dbsync                50
pip_install          105
apt-get-update         2
run_process           48
git_timed              2
-------------------------
Unaccounted time     942
=========================
Total runtime        2533

=================
 Async summary
=================
 Time spent in the background minus waits: 1124 sec
 Elapsed time: 2533 sec
 Time if we did everything serially: 3657 sec
 Speedup:  1.44374


Post-stack database query stats:
+------------+-----------+-------+
| db         | op        | count |
+------------+-----------+-------+
| keystone   | INSERT    |   101 |
| keystone   | UPDATE    |     7 |
| keystone   | SELECT    | 27939 |
| glance     | DESCRIBE  |     4 |
| neutron    | DESCRIBE  |     4 |
| neutron    | CREATE    |   318 |
| neutron    | SHOW      |    60 |
| neutron    | SELECT    |  7580 |
| neutron    | INSERT    |  4235 |
| neutron    | UPDATE    |   338 |
| neutron    | ALTER     |   182 |
| neutron    | DROP      |   114 |
| neutron    | DELETE    |    64 |
| nova_api   | DESCRIBE  |     2 |
| nova_api   | CREATE    |    44 |
| nova_cell0 | DESCRIBE  |     2 |
| nova_cell0 | CREATE    |   200 |
| nova_cell1 | DESCRIBE  |     2 |
| nova_cell1 | CREATE    |   197 |
| nova_cell0 | ALTER     |     2 |
| nova_cell0 | SHOW      |    59 |
| nova_cell0 | SELECT    |    71 |
| nova_cell1 | ALTER     |     2 |
| nova_cell1 | SHOW      |    59 |
| nova_cell1 | SELECT    |   266 |
| placement  | SELECT    |    78 |
| placement  | INSERT    |    62 |
| placement  | SET       |     2 |
| nova_api   | SELECT    |    65 |
| nova_cell0 | INSERT    |     5 |
| nova_cell0 | UPDATE    |    23 |
| nova_cell1 | UPDATE    |   139 |
| glance     | INSERT    |    22 |
| glance     | SELECT    |    69 |
| glance     | UPDATE    |     6 |
| placement  | UPDATE    |     3 |
| nova_cell1 | INSERT    |     4 |
| nova_api   | INSERT    |    23 |
| nova_api   | SAVEPOINT |    11 |
| nova_api   | RELEASE   |    11 |
| nova_cell1 | DELETE    |     2 |
| keystone   | DELETE    |    17 |
+------------+-----------+-------+



This is your host IP address: 192.168.100.65
This is your host IPv6 address: ::1
Horizon is now available at http://192.168.100.65/dashboard
Keystone is serving at http://192.168.100.65/identity/
The default users are: admin and demo
The password: password

WARNING:
Configuring uWSGI with a WSGI file is deprecated, use module paths instead
Configuring uWSGI with a WSGI file is deprecated, use module paths instead
Configuring uWSGI with a WSGI file is deprecated, use module paths instead


Services are running under systemd unit files.
For more information see:
https://docs.openstack.org/devstack/latest/systemd.html

DevStack Version: 2025.1
Change: 9486709dc5e6f156dc5beb051f1861ea362ae10c Revert "Install simplejson in devstack venv" 2024-12-03 17:15:40 +0000
OS Version: Ubuntu 24.04 noble


INST_IP=10.0.0.37
scp -O test_server.bin cirros@${INST_IP}:
ssh -f cirros@${INST_IP} ./test_server.bin -id ${INST_IP}

INST_IP=10.0.0.16
scp -O test_server.bin cirros@${INST_IP}:
ssh -f cirros@${INST_IP} ./test_server.bin -id ${INST_IP}


ssh -f -L 127.0.0.1:6080:192.168.100.65:6080 root@87.228.27.178 -N

