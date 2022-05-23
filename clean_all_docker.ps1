docker container ls --quiet | %{ docker stop $_ }
docker container ls --quiet --all | %{ docker rm $_ }
docker image prune --force
