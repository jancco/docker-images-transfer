#!/usr/bin/env bash


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
	k8s.gcr.io_kubernetes-dashboard-amd64
	k8s.gcr.io_pause)

host_name=$(hostname)

. ./pull_image.sh "IMPORT"

for trans_image_name in ${trans_image_names[@]} ; do
    pull_image "${trans_image_name}" "${host_name}"
done
