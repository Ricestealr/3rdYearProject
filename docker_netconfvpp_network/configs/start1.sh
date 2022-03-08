#!/bin/bash

#netopeer2-server -d -v 4
#sysrepoctl -i /netconf/sysrepo/examples/plugin/oven.yang
sysrepoctl -i /netconf/hicn/ctrl/sysrepo-plugins/yang/ondemand.yang
vpp -c /configs/startup_hicn.conf
netopeer2-server
sysrepo-plugind
/configs/config1.sh
