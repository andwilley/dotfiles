function workspace_start -d "Start the Docker dev workspace"
    # Default container name
    set -l container_name "workspace"

    if test -n "$argv[1]"
        set container_name $argv[1]
    end

    if not docker network inspect dev-net >/dev/null 2>&1
        echo "Creating network: dev-net..."
        docker network create dev-net
    end

    if docker ps -a --format '{{.Names}}' | grep -Eq "^$container_name\$"
        echo "Container '$container_name' already exists. Starting it..."
        docker start $container_name
    else
        echo "Creating and starting new '$container_name' container..."
        docker run -it -d --name $container_name \
            -p 8080:8080 -p 2222:22 -p 3000:3000 --network dev-net \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v ~/projects:/home/rafiki/projects \
            debian:bookworm
    end
end
