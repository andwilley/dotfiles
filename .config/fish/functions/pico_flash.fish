# Copy firmware onto a pico over USB. Takes the path pico_build printed, plus
# any extra picotool arguments. The board must be attached to this machine and
# in BOOTSEL mode.
function pico_flash -a artifact -d "Flash a pico artifact over USB"
    if test -z "$artifact"
        echo "usage: pico_flash <artifact.uf2|.elf> [picotool args...]" >&2
        echo "       pico_build prints the path it produced." >&2
        return 2
    end
    if not test -f "$artifact"
        echo "pico_flash: no such file: $artifact" >&2
        return 1
    end
    if not command -q picotool
        echo "pico_flash: picotool not found (brew install picotool, apt install picotool)." >&2
        return 1
    end

    set -e argv[1]
    picotool load -x "$artifact" $argv
    set -l rc $status

    # Containers get no USB devices, so suggest the host. Paths are relative,
    # so the same command works there if the project is on a shared mount.
    if test $rc -ne 0; and test -f /.dockerenv -o -f /run/.containerenv
        echo "pico_flash: a container cannot see USB devices. On the host:" >&2
        echo "    pico_flash $artifact" >&2
    end
    return $rc
end
