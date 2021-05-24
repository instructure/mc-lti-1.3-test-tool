set +e
docker-compose run --rm web gergich publish
docker-compose kill
docker-compose rm -f
docker images -qf "dangling=true" | xargs docker rmi -f &>/dev/null
