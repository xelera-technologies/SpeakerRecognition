#!/bin/sh

tagname="1.0"
imagename="aws-dla-demo"
registryname="containerhub.xelera.io:4433" #public repo
​
docker run --rm -it --name cont-${imagename} --net=host --memory-swap=-1 --log-driver=none --device /dev/dri --privileged -p 8088:8088 ${registryname}/${imagename}:${tagname}
