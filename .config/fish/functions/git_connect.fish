function git_connect
    echo "Logging into GitHub..."
    if not gh auth login -h github.com -s admin:public_key
        echo "GitHub authentication failed. Aborting."
        return 1
    end

    set -l ssh_key_path "$HOME/.ssh/github_key"
    set -l ssh_config_path "$HOME/.ssh/config"

    if test -f "$ssh_key_path"
        echo "SSH key file already exists at $ssh_key_path. Aborting to prevent overwrite."
        echo "Please remove or rename the existing file if you wish to generate a new one."
        return 1
    end

    echo "Generating a new SSH key..."
    ssh-keygen -t ed25519 -f "$ssh_key_path" -N ""

    mkdir -p (dirname "$ssh_config_path")
    touch "$ssh_config_path"

    set -l config_entry "Host github.com
  IdentityFile $ssh_key_path"

    if not grep -q "Host github.com" "$ssh_config_path"
        echo "Updating SSH config for github.com..."
        echo -e "\n$config_entry" >> "$ssh_config_path"
    else
        echo "SSH config entry for 'Host github.com' already exists. Skipping update."
        echo "Please review your configuration manually at $ssh_config_path"
    end

    echo "Uploading SSH key to GitHub..."
    set -l key_title "cloud-dev-env-"(date +%s)
    if gh ssh-key add "$ssh_key_path.pub" -t "$key_title"
        echo "Successfully connected to GitHub!"
    else
        echo "Failed to upload SSH key to GitHub."
        return 1
    end
end
