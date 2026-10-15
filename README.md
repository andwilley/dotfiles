Hidden steps
* run the ansible play setup.yml
* install coreutils on mac
* Fira mono nerd: https://www.nerdfonts.com/font-downloads
* set fish as default shell `(chsh -s (which fish)`
* before opening nvim, update the .config/nvim repo

## Dev containers

Helpers are in `.config/fish/functions/`. Run these from the Mac; needs the full
`ansible` package, which bundles `community.docker`.

Create/start a container (default name `workspace`):

```fish
workspace_start rust
```

Only one container can publish 8080/2222/3000, so any additional one needs
`workspace_start embed --no-ports`.

Provision it — the play installs its own python3, no prep needed:

```fish
ansible-playbook -i 'rust,' -c community.docker.docker setup.yml \
    -e "dev_user_password=YourSecret" --tags "base,go,rust"
```

Trailing comma is required. Several at once: `-i 'rust,workspace,'`.
Tags are listed at the top of `setup.yml`.

Enter it (defaults: container `workspace`, user `rafiki`):

```fish
workspace_enter rust
```

Once inside, for docker-out-of-docker via the mounted socket:

```fish
d_out_d
```

## Embedded

AVR and Raspberry Pi Pico: see [embedded.md](embedded.md).
