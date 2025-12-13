function run_workspace
    set -l DOCKER_TAG $argv[1]
    if test -z "$DOCKER_TAG"
        set DOCKER_TAG "basic"
    end
    set -l USERNAME $argv[2]
    if test -z "$USERNAME"
        set USERNAME "rafiki"
    end
    echo "Starting workspace with tag: $DOCKER_TAG"
    docker network create dev-net; or true
    docker run -it -d --name workspace-$DOCKER_TAG \
        -p 8080:8080 -p 2222:22 -p 3000:3000 \
        --network dev-net \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v ~/projects:/home/$USERNAME/projects \
        andwilley/workstations:$DOCKER_TAG
end
