#!/bin/bash
VPPCTL=vppctl
CLISOCK1=/run/vpp/cli.sock


mkdir /shared/vpp

typeset -i cnt=60
until ls -l $CLISOCK1 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

$VPPCTL -s $CLISOCK1 create memif socket id 6 filename /shared/vpp/memif6.sock
$VPPCTL -s $CLISOCK1 create interface memif id 0 socket-id 6 master
#$VPPCTL -s $CLISOCK1 create host-interface name eth0
sleep 1
$VPPCTL -s $CLISOCK1 set interface ip address memif6/0 2000::4/64
sleep 1
$VPPCTL -s $CLISOCK1 set int state memif6/0 up
sleep 1
iface=$($VPPCTL -s $CLISOCK1 create loopback interface)
sleep 1
echo $iface
$VPPCTL -s $CLISOCK1 set interface state $iface up
sleep 1
$VPPCTL -s $CLISOCK1 set interface ip address $iface 5002::1/64
sleep 1
$VPPCTL -s $CLISOCK1 ip neighbor $iface 5002::2 de:ad:00:00:00:00


$VPPCTL -s $CLISOCK1 ip route add b001::/64 via 2000::5 memif6/0


#hicn config
$VPPCTL -s $CLISOCK1 hicn pgen client src 5001::2 name b001::1/64 intfc memif6/0
sleep 1
$VPPCTL -s $CLISOCK1 hicn enable b001::/64
sleep 1
$VPPCTL -s $CLISOCK1 exec /configs/pg.conf
sleep 1

$VPPCTL -s $CLISOCK1 trace add memif-input 50

