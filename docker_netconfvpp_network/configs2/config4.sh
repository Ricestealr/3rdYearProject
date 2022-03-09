#!/bin/bash
VPPCTL=vppctl
CLISOCK4=/run/vpp/cli.sock


typeset -i cnt=60
until ls -l $CLISOCK4 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

$VPPCTL -s $CLISOCK4 create memif socket id 3 filename /shared/vpp/memif3.sock
sleep 1
$VPPCTL -s $CLISOCK4 create interface memif id 0 socket-id 3 slave
sleep 1
#$VPPCTL -s $CLISOCK4 create host-interface name eth0
sleep 1
$VPPCTL -s $CLISOCK4 set interface ip address memif3/0 2003::5/64
sleep 1
$VPPCTL -s $CLISOCK4 set int state memif3/0 up
sleep 1
$VPPCTL -s $CLISOCK4 create memif socket id 4 filename /shared/vpp/memif4.sock
sleep 1
#$VPPCTL -s $CLISOCK4 create host-interface name eth1
$VPPCTL -s $CLISOCK4 create interface memif id 0 socket-id 4 master
sleep 1
$VPPCTL -s $CLISOCK4 set interface ip address memif4/0 2004::4/64
sleep 1
$VPPCTL -s $CLISOCK4 set int state memif4/0 up

$VPPCTL -s $CLISOCK4 ip route add 3::3/128 via 2004::5 memif4/0

$VPPCTL -s $CLISOCK4 hicn enable 3::3/128

$VPPCTL -s $CLISOCK4 trace add memif-input 50

