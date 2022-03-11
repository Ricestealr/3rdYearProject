#!/bin/bash

docker network create --ipv6 --subnet="2000::/64" --gateway="2000::1" vppnet1
docker network create --ipv6 --subnet="2001::/64" --gateway="2001::1" vppnet2
docker network create --ipv6 --subnet="2002::/64" --gateway="2002::1" vppnet3
docker network create --ipv6 --subnet="2003::/64" --gateway="2003::1" vppnet4
docker network create --ipv6 --subnet="2004::/64" --gateway="2004::1" vppnet5
docker network create --ipv6 --subnet="2005::/64" --gateway="2005::1" vppnet6
docker-compose up
