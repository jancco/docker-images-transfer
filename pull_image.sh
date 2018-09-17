#!/usr/bin/env bash

function pull_image() {
    trans_image_name=$1
    host_name=$2

    if [ ${host_name} ] ; then
        host_name_prefix="[${host_name}]"
    else
        host_name_prefix=""
    fi

	echo "${host_name_prefix}>>>> Pulling $trans_image_name ..."
	image_full_name="registry.cn-zhangjiakou.aliyuncs.com/jancco/$trans_image_name:latest"
    if [ $host_name ] ; then
        docker pull "$image_full_name" >> /dev/null
    else
        docker pull "$image_full_name"
    fi

    IFS='_' image_name_parts=($trans_image_name)
    image_name=${image_name_parts[-1]}
	origin_path=`docker inspect -f "{{index .Config.Labels \"origin-path\"}}" "$image_full_name"`
	version_tag=`docker inspect -f "{{index .Config.Labels \"version-tag\"}}" "$image_full_name"`
	image_origin_name=$origin_path/$image_name:$version_tag
	docker tag "$image_full_name" "$image_origin_name" >> /dev/null
	docker rmi "$image_full_name" >> /dev/null
	echo "${host_name_prefix}<<<< $image_origin_name updated!"
	echo ""

}

trans_image_name=$1

if [ -z $trans_image_name ] ; then
    echo "Argument trans_image_name required!"
elif [ $trans_image_name = "IMPORT" ] ; then
    return
else
    pull_image $1
fi
