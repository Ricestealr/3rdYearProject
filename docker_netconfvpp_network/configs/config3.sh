#!/bin/bash
VPPCTL=vppctl
CLISOCK3=/run/vpp/cli.sock


typeset -i cnt=60
until ls -l $CLISOCK3 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

$VPPCTL -s $CLISOCK3 create host-interface name eth0
sleep 1
$VPPCTL -s $CLISOCK3 set interface ip address host-eth0 2001::5/64
sleep 1
$VPPCTL -s $CLISOCK3 set int state host-eth0 up
sleep 1
$VPPCTL -s $CLISOCK3 create host-interface name eth1
sleep 1
$VPPCTL -s $CLISOCK3 set interface ip address host-eth1 2002::4/64
sleep 1
$VPPCTL -s $CLISOCK3 set int state host-eth1 up

$VPPCTL -s $CLISOCK3 ip route add 2::2/128 via 2002::5 host-eth1

$VPPCTL -s $CLISOCK3 ip route add 2000::/64 table 10 via 2001::4 host-eth0

#sleep 1
$VPPCTL -s $CLISOCK3 hicn enable 2::2/128
#sleep 1
$VPPCTL -s $CLISOCK3 trace add memif-input 50

