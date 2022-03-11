#!/bin/bash
VPPCTL=vppctl
CLISOCK6=/run/vpp/cli.sock


typeset -i cnt=60
until ls -l $CLISOCK6 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

#$VPPCTL -s $CLISOCK6 create host-interface name eth0
$VPPCTL -s $CLISOCK6 create memif socket id 5 filename /shared/vpp/memif5.sock
sleep 1
$VPPCTL -s $CLISOCK6 create interface memif id 0 socket-id 5 slave
sleep 1
$VPPCTL -s $CLISOCK6 set interface ip address memif5/0 2005::5/64
sleep 1
$VPPCTL -s $CLISOCK6 set int state memif5/0 up

$VPPCTL -s $CLISOCK6 ip route add 2002::/64 table 10 via 2005::4 memif5/0

#$VPPCTL -s $CLISOCK6 ip route add 2004::/64 table 10 via 2005::4 memif5/0

$VPPCTL -s $CLISOCK6 hicn pgen server name b001::1/64 intfc memif5/0

$VPPCTL -s $CLISOCK6 trace add memif-input 50
