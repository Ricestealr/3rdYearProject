#!/bin/bash

 
#netopeer2-server -d -v 4
#sysrepoctl -i /netconf/sysrepo/examples/plugin/oven.yang
sysrepoctl -i /netconf/hicn/ctrl/sysrepo-plugins/yang/ondemand.yang
vpp -c startup_nohicn.conf
netopeer2-server
sysrepo-plugind -d -v 4
