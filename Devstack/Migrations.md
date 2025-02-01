# Migrations

### ВМ ``instance1`` перенесена (**Сold**) с **HV devstack-1** на -> **HV devstack-2**:
```commandline
stack@devstack-2:~$ openstack server stop instance1
stack@devstack-2:~$ openstack server list
+--------------------------------------+-----------+---------+---------------------------------------------+--------------------------+---------+
| ID                                   | Name      | Status  | Networks                                    | Image                    | Flavor  |
+--------------------------------------+-----------+---------+---------------------------------------------+--------------------------+---------+
| 4d6df57d-4c7a-4481-89a8-541b1f17a528 | instance2 | ACTIVE  | private=10.12.0.40, fd::f816:3eff:fe3f:91ce | cirros-0.6.3-x86_64-disk | m1.tiny |
| 961f13d2-cb26-47cb-a760-c68f2b8aabea | instance1 | SHUTOFF | private=10.12.0.33, fd::f816:3eff:fe26:d3ee | cirros-0.6.3-x86_64-disk | m1.tiny |
+--------------------------------------+-----------+---------+---------------------------------------------+--------------------------+---------+
stack@devstack-2:~$ openstack server migrate --host devstack-2 instance1 --wait -v
Complete, check success/failure by openstack server migration/event list/show
```

### ВМ ``instance2`` перенесена (**Live**) с **HV devstack-3** на -> **HV devstack-2**:
```commandline
stack@devstack-2:~$ openstack server migrate --host devstack-2 instance2 --wait -v
Complete, check success/failure by openstack server migration/event list/show
```

### Confirm resize
```commandline
stack@devstack-2:~$ openstack server list
+--------------------------------------+-----------+---------------+---------------------------------------------+--------------------------+---------+
| ID                                   | Name      | Status        | Networks                                    | Image                    | Flavor  |
+--------------------------------------+-----------+---------------+---------------------------------------------+--------------------------+---------+
| 4d6df57d-4c7a-4481-89a8-541b1f17a528 | instance2 | VERIFY_RESIZE | private=10.12.0.40, fd::f816:3eff:fe3f:91ce | cirros-0.6.3-x86_64-disk | m1.tiny |
| 961f13d2-cb26-47cb-a760-c68f2b8aabea | instance1 | VERIFY_RESIZE | private=10.12.0.33, fd::f816:3eff:fe26:d3ee | cirros-0.6.3-x86_64-disk | m1.tiny |
+--------------------------------------+-----------+---------------+---------------------------------------------+--------------------------+---------+

stack@devstack-2:~$ openstack server resize confirm instance1
stack@devstack-2:~$ openstack server resize confirm instance2
stack@devstack-2:~$ openstack server start instance1
stack@devstack-2:~$ openstack server list
+--------------------------------------+-----------+--------+---------------------------------------------+--------------------------+---------+
| ID                                   | Name      | Status | Networks                                    | Image                    | Flavor  |
+--------------------------------------+-----------+--------+---------------------------------------------+--------------------------+---------+
| 4d6df57d-4c7a-4481-89a8-541b1f17a528 | instance2 | ACTIVE | private=10.12.0.40, fd::f816:3eff:fe3f:91ce | cirros-0.6.3-x86_64-disk | m1.tiny |
| 961f13d2-cb26-47cb-a760-c68f2b8aabea | instance1 | ACTIVE | private=10.12.0.33, fd::f816:3eff:fe26:d3ee | cirros-0.6.3-x86_64-disk | m1.tiny |
+--------------------------------------+-----------+--------+---------------------------------------------+--------------------------+---------+

```

### Оба хоста up & running:
```commandline
stack@devstack-2:~$ nmap 10.12.0.33
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-12-12 14:50 MSK
Nmap scan report for 10.12.0.33
Host is up (0.0051s latency).
Not shown: 997 filtered tcp ports (no-response)
PORT     STATE  SERVICE
22/tcp   open   ssh
80/tcp   closed http
8080/tcp closed http-proxy

Nmap done: 1 IP address (1 host up) scanned in 4.48 seconds
stack@devstack-2:~$ nmap 10.12.0.40
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-12-12 14:50 MSK
Nmap scan report for 10.12.0.40
Host is up (0.0014s latency).
Not shown: 997 filtered tcp ports (no-response)
PORT     STATE  SERVICE
22/tcp   open   ssh
80/tcp   closed http
8080/tcp closed http-proxy

Nmap done: 1 IP address (1 host up) scanned in 4.75 seconds
```