#!/usr/bin/env bash

: ${K8S_MASTER_NODES:="k8s-m1 k8s-m2 k8s-m3"}
: ${K8S_WORKER_NODES:="k8s-g1 k8s-g2"}
: ${K8S_NODES:="${K8S_MASTER_NODES} ${K8S_WORKER_NODES}"}

SCRIPT_DIR=~

echo "To update nodes: ${K8S_NODES} ..."

# Update all nodes
for NODE in ${K8S_NODES}; do
  # Copy script file
  scp pull_images.sh ${NODE}:${SCRIPT_DIR}/ >> /dev/null
  # Update kuberneter images and clean incomplete ones
  ssh ${NODE} ". ${SCRIPT_DIR}/pull_images.sh -g k8s -s -c" &
done

echo "All nodes updated!"