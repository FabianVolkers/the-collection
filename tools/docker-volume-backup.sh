#!/bin/bash

day=$(date "+%Y_%m_%d")

mkdir -p /docker/volumes/$day

services=$(docker service ls | grep replicated | awk '{print $2}')

volumes=$(docker volume ls --format "{{.Name}}")
delete=VOLUME
volumes=( "${volumes[@]/$delete}" )

archived_volumes=()

for volume in $volumes; do

    printf "Archiving volume %s\n" $volume

    volume_services=()

    # find services using volume
    for service in $services; do

        service_volumes=$(docker service inspect --format '{{ range .Spec.TaskTemplate.ContainerSpec.Mounts }}{{ if eq .Type "volume" }}{{.Source }}{{ end }}{{ end }}' $service)

        for vol in $service_volumes; do
            if [ $vol == $volume ]; then
		printf "\nFound volume %s mounted for service %s\n" $vol $service
                volume_services+=($service)
            fi
        done

    done

    # shut down services
    initial_scales=()
    for service in $volume_services; do

        initial_scale=$(docker service inspect --format \
            '{{ .Spec.Mode.Replicated.Replicas }}' $service)

        initial_scales+=($initial_scale)

        # Stop all runnning instances  of the service
        printf "\nScaling down service %s\n" $service
        docker service scale $service=0

    done
    if [ -n $volume_services ]; then
    	# archive volume
    	timestamp=$(date "+%Y_%m_%d__%H_%M_%S")
    	filename="/backup/${day}/${volume}_${timestamp}.tar"

    	# Run archiving container
    	docker run --rm \
            -v $volume:/backup_volumes/$volume \
            -v /docker/volumes:/backup ubuntu bash \
            -c "cd /backup_volumes && tar cf $filename $volume --totals"

    	if [ $? -eq 0 ]; then
            printf "\nsuccessfully archived %s to %s\n" $volume $filename
            archived_volumes+=($volume)
        else
            printf "\nerror archiving %s\n" $volume
        fi
    fi
    # restart services
    for ((i=0;i<${#volume_services[@]};++i)); do
        service=${volume_services[i]}
        initial_scale=${initial_scales[i]}
        # Scale services back up
        docker service scale $service=$initial_scale
        if [ $? -eq 0 ]; then
            printf '\nsuccessfully scaled service %s back up\n' $service
            archived_volumes+=($volume)
        else
            printf "\nerror scaling service %s back up\n" $service
        fi
    done

    printf "\n-------------------------------------------------------------------\n\n"

done
