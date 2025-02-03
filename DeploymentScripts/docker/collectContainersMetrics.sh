#!/bin/bash
# Loop from 1 to 10
for ((i = 1; i <= 10; i++)); do
        docker ps -a --format "{{.Names}} {{if eq .State \"running\"}}1{{else if eq .State \"paused\"}}2{{else if eq .State \"paused\"}}2{{else if eq .State \"exited\"}}3{{else if eq .State \"restarting\"}}4{{else if eq .State \"created\"}}5{{else if eq .State \"dead\"}}6{{else}}0{{end}}" | sed 's/-/_/g' | sed -r 's/(^|_)([a-z])/\U\2/g' | sed -r 's/^(.)/\l\1/g' |sed -e "s/\b\(.\)/\u\1/g"| while read line; do echo "$line" | curl --data-binary @- http://localhost:9091/metrics/job/container_status/instance/localhost; done
    sleep 30
done