if status is-interactive
    fish_vi_key_bindings
    # starship init fish | source

    set -gx EDITOR nvim
    set -gx VISUAL nvim

    # Mercurial abbreviations
    abbr --add hglisthead "hg status --rev p4base"
    abbr --add hglistlast "hg status --rev .^"

    # Arduino abbreviations
    abbr --add arduino_init "mkdir -p build && arduino-cli compile --only-compilation-database --build-path=build/ --export-binaries"
    abbr --add arduino_build "arduino-cli compile --export-binaries --build-path=build/"
    abbr --add arduino_up "arduino-cli upload --input-dir=build/"
    abbr --add arduino_buildup "arduino_build && arduino_up"

    # Work stuff
    if test -f ~/.goog/fish/config.fish
        # also calls: set -p fish_function_path ~/.goog/fish/functions
        source ~/.goog/fish/config.fish
    end

    # Non VCS local stuff
    if test -f ~/.local/fish/local.fish
        source ~/.local/fish/local.fish
    end

    # Turn off <C-s> functionality
    stty -ixon

    # Local paths
    fish_add_path ~/.local/bin
    fish_add_path ~/local/bin

    # Go setup
    set -gx GOPATH $HOME/go
    fish_add_path /usr/local/go/bin
    fish_add_path $GOPATH/bin

    # Homebrew (Conditional check)
    if test -d /opt/homebrew/bin
        fish_add_path /opt/homebrew/bin
    end

    # Lua & Rust setup
    fish_add_path $HOME/apps/lua-language-server/bin
    fish_add_path $HOME/.cargo/bin

    # --- Environment Variables ---
    set -gx MPW_FULLNAME "Andrew Willey"

    # --- OCaml / OPAM Configuration ---
    # WARNING: Fish cannot run the bash 'init.sh'. 
    # We use 'opam env' to generate the fish config dynamically.
    if type -q opam
        eval (opam env)
    end
end
