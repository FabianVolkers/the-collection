#!/bin/bash

sudo -v
echo "Creating Volume "  $1
volume_name=$1
error=false
sudo gluster volume create $volume_name replica 2 fra.fabianvolkers.com:/gluster/$volume_name isl.fabianvolkers.com:/gluster/$volume_name force
if [ $? -eq 0 ]; then
    echo "Successfully created gluster volume $volume_name"
else
    echo "Error creating volume $volume_name"
    error=true
fi

if [ $error == false ]; then
    sudo gluster volume start $volume_name
    if [ $? -eq 0 ]; then
        echo "Successfully started gluster volume $volume_name"
    else
        echo "Error starting volume $volume_name"
        error=true
    fi
fi

if [ $error == false ]; then
    docker volume create --name $volume_name --driver glusterfs
fi

