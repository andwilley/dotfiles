# Map a board name to its rust target triple, the name rustc uses for the
# architecture it compiles for.
function _pico_target -a board -d "Rust target triple for a pico board"
    switch $board
        case pico pico_w
            echo thumbv6m-none-eabi
        case pico2 pico2_w
            echo thumbv8m.main-none-eabihf
        case '*'
            echo "Unknown board '$board': expected pico, pico_w, pico2 or pico2_w." >&2
            return 1
    end
end
