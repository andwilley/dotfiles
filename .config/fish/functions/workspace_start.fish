function workspace_start -d "Start the Docker dev workspace"
    # Default container name
    set -l container_name "workspace"

    # Ports collide if two workspaces publish them; pass --no-ports for extras
    set -l publish_ports true

    for arg in $argv
        switch $arg
            case --no-ports
                set publish_ports false
            case '*'
                set container_name $arg
        end
    end

    if not docker network inspect dev-net >/dev/null 2>&1
        echo "Creating network: dev-net..."
        docker network create dev-net
    end

    if docker ps -a --format '{{.Names}}' | grep -Eq "^$container_name\$"
        echo "Container '$container_name' already exists. Starting it..."
        docker start $container_name
    else
        set -l port_args
        if test "$publish_ports" = true
            set port_args -p 8080:8080 -p 2222:22 -p 3000:3000
        else
            echo "Not publishing ports (--no-ports)."
        end

        echo "Creating and starting new '$container_name' container..."
        docker run -it -d --name $container_name \
            $port_args --network dev-net \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v ~/projects:/home/rafiki/projects \
            debian:trixie
    end
end
