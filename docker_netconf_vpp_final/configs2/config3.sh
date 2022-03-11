#!/bin/bash
VPPCTL=vppctl
CLISOCK3=/run/vpp/cli.sock


typeset -i cnt=60
until ls -l $CLISOCK3 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

$VPPCTL -s $CLISOCK3 create memif socket id 1 filename /shared/vpp/memif1.sock
sleep 1
$VPPCTL -s $CLISOCK3 create interface memif id 0 socket-id 1 slave
#$VPPCTL -s $CLISOCK3 create host-interface name eth0
sleep 1
$VPPCTL -s $CLISOCK3 set interface ip address memif1/0 2001::5/64
sleep 1
$VPPCTL -s $CLISOCK3 set int state memif1/0 up
sleep 1
#$VPPCTL -s $CLISOCK3 create host-interface name eth1
$VPPCTL -s $CLISOCK3 create memif socket id 2 filename /shared/vpp/memif2.sock
sleep 1
$VPPCTL -s $CLISOCK3 create interface memif id 0 socket-id 2 master
sleep 1
$VPPCTL -s $CLISOCK3 set interface ip address memif2/0 2002::4/64
sleep 1
$VPPCTL -s $CLISOCK3 set int state memif2/0 up

$VPPCTL -s $CLISOCK3 ip route add 2::2/128 via 2002::5 memif2/0

$VPPCTL -s $CLISOCK3 ip route add 2000::/64 table 10 via 2001::4 memif1/0

#sleep 1
$VPPCTL -s $CLISOCK3 hicn enable 2::2/128
#sleep 1
$VPPCTL -s $CLISOCK3 trace add memif-input 50

