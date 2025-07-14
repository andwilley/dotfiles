gh auth refresh -h github.com -s admin:public_key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/github_rsa -N ""
gh ssh-key add ~/.ssh/github_rsa.pub -t "cloud-dev-env-$(date +%s)"
