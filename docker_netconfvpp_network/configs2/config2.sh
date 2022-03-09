#!/bin/bash
VPPCTL=vppctl
CLISOCK2=/run/vpp/cli.sock


typeset -i cnt=60
until ls -l $CLISOCK2 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

$VPPCTL -s $CLISOCK2 create memif socket id 6 filename /shared/vpp/memif6.sock
$VPPCTL -s $CLISOCK2 create interface memif id 0 socket-id 6 slave
#$VPPCTL -s $CLISOCK2 create host-interface name eth0
sleep 1
$VPPCTL -s $CLISOCK2 set interface ip address memif6/0 2000::5/64
sleep 1
$VPPCTL -s $CLISOCK2 set int state memif6/0 up
sleep 1
$VPPCTL -s $CLISOCK2 create memif socket id 1 filename /shared/vpp/memif1.sock
sleep 1
#$VPPCTL -s $CLISOCK2 create host-interface name eth1
$VPPCTL -s $CLISOCK2 create interface memif id 0 socket-id 1 master
sleep 1
$VPPCTL -s $CLISOCK2 set interface ip address memif1/0 2001::4/64
sleep 1
$VPPCTL -s $CLISOCK2 set int state memif1/0 up
sleep 1
#$VPPCTL -s $CLISOCK2 create host-interface name eth2
$VPPCTL -s $CLISOCK2 create memif socket id 3 filename /shared/vpp/memif3.sock
sleep 1
$VPPCTL -s $CLISOCK2 create interface memif id 0 socket-id 3 master
sleep 1
$VPPCTL -s $CLISOCK2 set interface ip address memif3/0 2003::4/64
sleep 1
$VPPCTL -s $CLISOCK2 set int state memif3/0 up


#routing
$VPPCTL -s $CLISOCK2 ip route add 2::2/128 via 2001::5 memif1/0
#sleep 1
$VPPCTL -s $CLISOCK2 ip route add 3::3/128 via 2003::5 memif3/0

$VPPCTL -s $CLISOCK2 trace add memif-input 50


$VPPCTL -s $CLISOCK2 set sr encaps source addr 1::1
sleep 1
$VPPCTL -s $CLISOCK2 sr policy add bsid 1::1:999 next 3::3 encap
sleep 1
$VPPCTL -s $CLISOCK2 sr steer l3 b001::/64 via bsid 1::1:999
