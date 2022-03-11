#!/bin/bash
docker exec vpp2 python3 testVPP.py &
sleep 1
docker exec vpp1 vppctl packet-generator enable-stream hicn-pg
