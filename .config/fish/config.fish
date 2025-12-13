if status is-interactive
    fish_vi_key_bindings
    starship init fish | source

    # Mercurial abbreviations
    abbr --add hglisthead "hg status --rev p4base"
    abbr --add hglistlast "hg status --rev .^"

    # Arduino abbreviations
    abbr --add arduino_init "mkdir -p build && arduino-cli compile --only-compilation-database --build-path=build/ --export-binaries"
    abbr --add arduino_build "arduino-cli compile --export-binaries --build-path=build/"
    abbr --add arduino_up "arduino-cli upload --input-dir=build/"
    abbr --add arduino_buildup "arduino_build && arduino_up"

    # ATOM ONE LIGHT - Syntax Highlighting
    # ------------------------------------
    set -g fish_color_normal normal           # Default text
    set -g fish_color_command 4078f2 --bold   # Commands (Blue)
    set -g fish_color_keyword a626a4          # Keywords like if/for (Purple)
    set -g fish_color_quote 50a14f            # Strings (Green)
    set -g fish_color_redirection e45649      # Redirections > (Red)
    set -g fish_color_end 4078f2              # Separators ; & (Blue)
    set -g fish_color_error e45649 --bold     # Invalid commands (Red)
    set -g fish_color_param 383a42            # Arguments/Flags (Dark Grey)
    set -g fish_color_comment a0a1a7 --italic # Comments (Light Grey)
    set -g fish_color_selection --background=e5e5e6 # Selection background
    set -g fish_color_search_match --background=e5e5e6 # Search match background
    set -g fish_color_operator 986801         # Operators (Orange/Brown)
    set -g fish_color_escape 0184bc           # Escape chars (Cyan-ish)
    set -g fish_color_autosuggestion a0a1a7   # Autosuggestions (Light Grey)
    
    # Pager (The completion menu)
    set -g fish_pager_color_progress 383a42 --background=e5e5e6
    set -g fish_pager_color_prefix 4078f2 --bold --underline
    set -g fish_pager_color_completion 383a42
    set -g fish_pager_color_description 383a42
    set -g fish_pager_color_selected_background c0c0c0
    set -g fish_pager_color_selected_completion 383a42 --bold
end
