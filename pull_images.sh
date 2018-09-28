#!/usr/bin/env bash

k8s_img_names=( \
    gcr.io_google_containers_defaultbackend
	gcr.io_google_containers_metrics-server-amd64
	k8s.gcr.io_coredns
	k8s.gcr.io_elasticsearch
	k8s.gcr.io_etcd-amd64
	k8s.gcr.io_fluentd-elasticsearch
	k8s.gcr.io_kube-apiserver-amd64
	k8s.gcr.io_kube-controller-manager-amd64
	k8s.gcr.io_kube-proxy-amd64
	k8s.gcr.io_kube-scheduler-amd64
	k8s.gcr.io_kubernetes-dashboard-amd64
	k8s.gcr.io_pause)

function pull_image() {
	trans_image_name=$1
	host_name=$2

	if [[ ${host_name} = "" ]] ; then
		host_name_prefix=""
	else
		host_name_prefix="[${host_name}]"
	fi

	echo "${host_name_prefix}>>>> Pulling $trans_image_name ..."
	image_full_name="registry.cn-zhangjiakou.aliyuncs.com/jancco/$trans_image_name:latest"
	if [[ $host_name ]] ; then
		docker pull "$image_full_name" >> /dev/null
	else
		docker pull "$image_full_name"
	fi

	image_name_parts=(`echo $trans_image_name | tr '_' ' '`)
	image_name=${image_name_parts[-1]}
	origin_path=`docker inspect -f "{{index .Config.Labels \"origin-path\"}}" "$image_full_name"`
	version_tag=`docker inspect -f "{{index .Config.Labels \"version-tag\"}}" "$image_full_name"`
	image_origin_name=$origin_path/$image_name:$version_tag
	docker tag "$image_full_name" "$image_origin_name" >> /dev/null
	docker rmi "$image_full_name" >> /dev/null
	echo "${host_name_prefix}<<<< $image_origin_name updated!"
	echo ""
}

args=("$@")
img_names=()
img_grp=""
show_host=false
clear_img=false

for (( i=0; i<$#; i++ )) ; do
	arg=${args[$i]}
	case $arg in
		-g) # image group
			if (( $i == $[$# - 1] )) ; then
				echo "Image group shoud be given after -g!"
				return 0
			else
				img_grp=${args[$i+1]}
				((i++))
			fi
			;;
		-s) # show hostname
			show_host=true
			;;
		-c) # clear obsolete images
			clear_img=true
			;;
		-*) # unsupported flags
			echo "Unrecognized flag: ${arg}!"
			return 0
	 		;;
		*) # image name
			img_names+=("${arg}")
	 		;;
	esac
done

# To handle image names
if [[ $img_grp = "k8s" ]] ; then
	img_names+=("${k8s_img_names[@]}")
fi

# Eliminate duplicated image names
img_names=(`echo "${img_names[@]}" | tr ' ' '\n' | awk '!a[$0]++'`)

if (( ${#img_names[@]} == 0 )) ; then
	echo "Image names cannot be empty!"
	return 0
fi

# To handle show_host
if [[ $show_host = true ]] ; then
	host_name=$(hostname)
else
	host_name=""
fi

# Pull images
for trans_image_name in "${img_names[@]}" ; do
	pull_image "$trans_image_name" $host_name
done

# Clear obsolete images, say those with '<none>' tag
if [[ $clear_img = true ]] ; then
	docker images | grep '<none>' | awk '{print $3}' | xargs -r docker rmi >> /dev/null
fi
