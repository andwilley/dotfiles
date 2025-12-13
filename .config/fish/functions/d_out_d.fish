function d_out_d
    set -l user $argv[1]
    if test -z "$user"
        set user (whoami)
    end
    set -l socket_path "/var/run/docker.sock"

    if not test -S "$socket_path"
        echo "Error: Docker socket not found at $socket_path." >&2
        return 1
    end

    set -l docker_gid (stat -c '%g' "$socket_path")
    if not string match -qr '^[0-9]+$' "$docker_gid"
        echo "Error: Could not determine the group ID for $socket_path." >&2
        return 1
    end

    set -l docker_group (getent group "$docker_gid" | cut -d: -f1)
    if test -z "$docker_group"
        set docker_group "$docker_gid"
    end

    if test "$docker_group" = "root"
        set -l new_group "docker_access"
        if not getent group "$new_group" > /dev/null
            if not sudo groupadd "$new_group"
                echo "Error: Failed to create group '$new_group'. Check sudo permissions." >&2
                return 1
            end
        end
        if not sudo chgrp "$new_group" "$socket_path"
            echo "Error: Failed to change group of $socket_path." >&2
            return 1
        end
        set docker_group "$new_group"
    end

    if not id -nG "$user" | grep -qw "$docker_group"
        if not sudo usermod -aG "$docker_group" "$user"
            echo "Error: Failed to add user '$user' to group '$docker_group'." >&2
            return 1
        end
        echo "Success! User '$user' has been added to the '$docker_group' group."
        echo "IMPORTANT: For the new group membership to take effect, you must start a new shell session (or log out and log back in)."
    end
end
