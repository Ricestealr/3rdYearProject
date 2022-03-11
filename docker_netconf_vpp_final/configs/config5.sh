#!/bin/bash
VPPCTL=vppctl
CLISOCK5=/run/vpp/cli.sock


typeset -i cnt=60
until ls -l $CLISOCK5 ; do
       ((cnt=cnt-1)) || exit 1
       sleep 1
done

$VPPCTL -s $CLISOCK5 create host-interface name eth0 
sleep 1
$VPPCTL -s $CLISOCK5 set interface ip address host-eth0 2002::5/64
$VPPCTL -s $CLISOCK5 set int state host-eth0 up
sleep 1
$VPPCTL -s $CLISOCK5 create host-interface name eth1
sleep 1
$VPPCTL -s $CLISOCK5 set interface ip address host-eth1 2004::5/64
$VPPCTL -s $CLISOCK5 set int state host-eth1 up
sleep 1
$VPPCTL -s $CLISOCK5 create host-interface name eth2
sleep 1
$VPPCTL -s $CLISOCK5 set interface ip address host-eth2 2005::4/64
sleep 1
$VPPCTL -s $CLISOCK5 set int state host-eth2 up

sleep 1
$VPPCTL -s $CLISOCK5 sr localsid address 2::2 behavior end.dx6 host-eth2 2005::5
sleep 1
$VPPCTL -s $CLISOCK5 sr localsid address 3::3 behavior end.dx6 host-eth2 2005::5

$VPPCTL -s $CLISOCK5 trace add af-packet-input 50

