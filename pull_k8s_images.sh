#!/bin/bash

image_names=(metrics-server-amd64 defaultbackend kube-proxy-amd64 kubernetes-dashboard-amd64 fluentd-elasticsearch
    elasticsearch coredns kube-scheduler-amd64 kube-apiserver-amd64 kube-controller-manager-amd64)

for image_name in ${image_names[@]} ; do
	image_full_name=jancco/$image_name:latest
	echo ">>>> Pulling $image_full_name ..."
	docker pull $image_full_name

	origin_path=`docker inspect -f "{{index .Config.Labels \"origin-path\"}}" $image_full_name`
	version_tag=`docker inspect -f "{{index .Config.Labels \"version-tag\"}}" $image_full_name`
	docker tag $image_full_name $origin_path/$image_name:$version_tag >> /dev/null
	docker rmi $image_full_name >> /dev/null
	echo "$image_full_name updated!"
	echo ""
done

