#!/bin/bash


### Выполнять после ребута
ip a add 192.168.12.10/25 dev br-ex; ip l set up br-ex; ip l set up br-int  # Node1
ip a add 192.168.12.20/25 dev br-ex; ip l set up br-ex; ip l set up br-int  # Node2
ip a add 192.168.12.30/25 dev br-ex; ip l set up br-ex; ip l set up br-int  # Node3

