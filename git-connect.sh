gh auth refresh -h github.com -s admin:public_key
ssh-keygen -t ed25519 -f ~/.ssh/github_key -N ""
touch ~/.ssh/config
cat > ~/.ssh/config << EOM
Host github.com
    IdentityFile ~/.ssh/github_key
EOM
gh ssh-key add ~/.ssh/github_key.pub -t "cloud-dev-env-$(date +%s)"
