# Open a serial console to the pico's USB port, for firmware built with stdio
# over USB. Takes a device path, or finds the first one itself. The board must
# be attached to this machine.
function pico_mon -a port -d "Serial console to the pico"
    if test -z "$port"
        set -l ports (find /dev -maxdepth 1 \( -name 'tty.usbmodem*' -o -name 'ttyACM*' \) 2>/dev/null)
        if test (count $ports) -eq 0
            echo "pico_mon: no USB serial device (/dev/tty.usbmodem* or /dev/ttyACM*)." >&2
            if test -f /.dockerenv -o -f /run/.containerenv
                echo "pico_mon: a container cannot see USB devices. Run it on the host." >&2
            end
            return 1
        end
        set port $ports[1]
    end

    if not command -q tio
        echo "pico_mon: tio not found (brew install tio, apt install tio)." >&2
        return 1
    end

    echo "pico_mon: $port (ctrl-t q to quit)"
    tio $port
end
