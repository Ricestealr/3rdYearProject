#!/bin/bash

 
#netopeer2-server -d -v 4
sysrepoctl -i /netconf/sysrepo/examples/plugin/oven.yang
sysrepoctl -i /netconf/hicn/ctrl/sysrepo-plugins/yang/hicn/hicn.yang
vpp -c startup1.conf
sysrepo-plugind -d -v 4
