function enter_workspace
    set -l DOCKER_TAG $argv[1]
    if test -z "$DOCKER_TAG"
        set DOCKER_TAG "basic"
    end
    docker exec -it workspace-$DOCKER_TAG /bin/bash -l
end
