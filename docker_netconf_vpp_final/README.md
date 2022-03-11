# 3rdYearProject

Docker file to build a docker image with sysrepo and netopeer installed

Build the image:
```console
user@machine:~/3rdYearProject/docker_netconf$ docker build -t netconf -f Dockerfile.netconf .
```

Run the image:
```console
user@machine:~/3rdYearProject/docker_netconf$ docker run netconf
```


Log into the docker:
```console
user@machine:~/3rdYearProject/docker_netconf$ docker exec -it CONTAINER_NAME /bin/bash
```

Run the ncclient test script:
```console
root@2509c484a485:/# python3 test.py
```
