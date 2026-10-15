# Build a pico project, with cmake for the pico-sdk or cargo for bare metal
# rust. Run it from the project root. Output goes to build/<board>, one
# directory per board, because cmake caches the board it configured with.
function pico_build -a board -d "Build a pico project into build/<board>"
    if test -z "$board"
        set board pico
        if set -q PICO_BOARD; and test -n "$PICO_BOARD"
            set board $PICO_BOARD
        end
    end

    set -l out build/$board

    if test -f Cargo.toml
        # A target triple is the name rustc uses for what it compiles for.
        # RP2040 and RP2350 are different cores, so they have different ones.
        set -l triple (_pico_target $board); or return 1
        cargo build --release --target $triple
        or return $status

        # Cargo writes a bare ELF deep under target/. Copy it into build/<board>
        # so both toolchains leave their output in the same place.
        set -l cands (find target/$triple/release -maxdepth 1 -type f -perm -u+x)
        if test (count $cands) -eq 0
            echo "pico_build: no executable in target/$triple/release." >&2
            return 1
        end
        set -l elf (ls -t $cands | head -1)
        mkdir -p $out
        cp $elf $out/(basename $elf).elf
    else
        if not set -q PICO_SDK_PATH
            echo "pico_build: PICO_SDK_PATH is unset -- point it at a pico-sdk checkout." >&2
            return 1
        end
        cmake -S . -B $out -G Ninja \
            -DPICO_BOARD=$board \
            -DCMAKE_BUILD_TYPE=RelWithDebInfo \
            -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
        or return $status
        cmake --build $out
        or return $status

        # clangd needs the cross compiler's own include paths. QueryDriver asks
        # the compiler for them; without it clangd uses the host's and fails to
        # find the headers.
        if not test -e .clangd
            printf 'CompileFlags:\n  CompilationDatabase: build/%s\n  QueryDriver: /usr/bin/arm-none-eabi-*\n' $board >.clangd
            echo "pico_build: wrote .clangd (database build/$board)"
        end
    end

    # Flashable output is at the top of build/<board>. Anything deeper belongs
    # to the build itself, such as the sdk's second stage bootloader.
    set -l arts (find $out -maxdepth 1 -type f -name '*.uf2')
    if test (count $arts) -eq 0
        set arts (find $out -maxdepth 1 -type f -name '*.elf')
    end
    if test (count $arts) -eq 0
        echo "pico_build: built, but no .uf2 or .elf in $out." >&2
        return 1
    end
    for a in $arts
        echo "pico_build: $a"
    end
end
