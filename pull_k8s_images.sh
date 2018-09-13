#!/bin/bash

trans_image_names=( \
    gcr.io_google_containers_defaultbackend
	gcr.io_google_containers_metrics-server-amd64
	k8s.gcr.io_coredns
	k8s.gcr.io_elasticsearch
	k8s.gcr.io_fluentd-elasticsearch
	k8s.gcr.io_kube-apiserver-amd64
	k8s.gcr.io_kube-controller-manager-amd64
	k8s.gcr.io_kube-proxy-amd64
	k8s.gcr.io_kube-scheduler-amd64
	k8s.gcr.io_kubernetes-dashboard-amd64)

for trans_image_name in ${trans_image_names[@]} ; do
	echo ">>>> Pulling $trans_image_name ..."
	image_full_name="registry.cn-zhangjiakou.aliyuncs.com/jancco/$trans_image_name:latest"
	docker pull "$image_full_name"

    IFS='_' image_name_parts=($trans_image_name)
    image_name=${image_name_parts[-1]}
	origin_path=`docker inspect -f "{{index .Config.Labels \"origin-path\"}}" "$image_full_name"`
	version_tag=`docker inspect -f "{{index .Config.Labels \"version-tag\"}}" "$image_full_name"`
	image_origin_name=$origin_path/$image_name:$version_tag
	docker tag "$image_full_name" "$image_origin_name" >> /dev/null
	docker rmi "$image_full_name" >> /dev/null
	echo "$image_origin_name updated!"
	echo ""
done

