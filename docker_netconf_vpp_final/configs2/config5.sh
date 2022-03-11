#!/bin/bash
VPPCTL=vppctl
CLISOCK5=/run/vpp/cli.sock


typeset -i cnt=60
until ls -l $CLISOCK5 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

$VPPCTL -s $CLISOCK5 create memif socket id 2 filename /shared/vpp/memif2.sock
sleep 1
$VPPCTL -s $CLISOCK5 create interface memif id 0 socket-id 2 slave
#$VPPCTL -s $CLISOCK5 create host-interface name eth0 
sleep 1
$VPPCTL -s $CLISOCK5 set interface ip address memif2/0 2002::5/64
$VPPCTL -s $CLISOCK5 set int state memif2/0 up
sleep 1
$VPPCTL -s $CLISOCK5 create memif socket id 4 filename /shared/vpp/memif4.sock
$VPPCTL -s $CLISOCK5 create interface memif id 0 socket-id 4 slave
#$VPPCTL -s $CLISOCK5 create host-interface name eth1
sleep 1
$VPPCTL -s $CLISOCK5 set interface ip address memif4/0 2004::5/64
$VPPCTL -s $CLISOCK5 set int state memif4/0 up
sleep 1
#$VPPCTL -s $CLISOCK5 create host-interface name eth2
$VPPCTL -s $CLISOCK5 create memif socket id 5 filename /shared/vpp/memif5.sock
sleep 1
$VPPCTL -s $CLISOCK5 create interface memif id 0 socket-id 5 master
sleep 1
$VPPCTL -s $CLISOCK5 set interface ip address memif5/0 2005::4/64
sleep 1
$VPPCTL -s $CLISOCK5 set int state memif5/0 up

sleep 1
$VPPCTL -s $CLISOCK5 sr localsid address 2::2 behavior end.dx6 memif5/0 2005::5
sleep 1
$VPPCTL -s $CLISOCK5 sr localsid address 3::3 behavior end.dx6 memif5/0 2005::5

$VPPCTL -s $CLISOCK5 trace add memif-input 50

