#!/bin/bash
VPPCTL=vppctl
CLISOCK4=/run/vpp/cli.sock


typeset -i cnt=60
until ls -l $CLISOCK4 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

$VPPCTL -s $CLISOCK4 create host-interface name eth0
sleep 1
$VPPCTL -s $CLISOCK4 set interface ip address host-eth0 2003::5/64
sleep 1
$VPPCTL -s $CLISOCK4 set int state host-eth0 up
sleep 1
$VPPCTL -s $CLISOCK4 create host-interface name eth1
sleep 1
$VPPCTL -s $CLISOCK4 set interface ip address host-eth1 2004::4/64
sleep 1
$VPPCTL -s $CLISOCK4 set int state host-eth1 up

$VPPCTL -s $CLISOCK4 ip route add 3::3/128 via 2004::5 host-eth1

$VPPCTL -s $CLISOCK4 hicn enable 3::3/128

$VPPCTL -s $CLISOCK4 trace add af-packet-input 50

