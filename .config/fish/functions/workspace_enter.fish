function workspace_enter -d "Enter the Docker dev workspace"
    # Default container name
    set -l container_name "workspace"
    
    # Default user name
    set -l user_name "rafiki"
    
    if test -n "$argv[1]"
        set container_name $argv[1]
    end

    if test -n "$argv[2]"
        set user_name $argv[2]
    end

    if not docker ps --format '{{.Names}}' | grep -Eq "^$container_name\$"
        echo "Error: Container '$container_name' is not running."
        echo "You can start it with: workspace_start $container_name"
        return 1
    end

    echo "Entering '$container_name' as user '$user_name'..."
    
    docker exec -u $user_name -it -w /home/$user_name $container_name fish -l
end
