# Embedded

The toolchain comes from the `embedded` tag in setup.yml, which covers AVR and
the Raspberry Pi Pico. The AVR tasks are also tagged `arduino` if that is all
you want.

Building works anywhere. Flashing and serial consoles need the board plugged
into the machine you run them on, so if you build in a container, run those
steps on the host.

## Arduino / AVR

1. Run the ansible play with the `embedded` tag.
1. A project should have
    * a sketch.yaml with `default_fqbn` and `default_port`
    * a header file that defines your namespace and `setup` and `loop`
    * a cpp file that implements `setup` and `loop`
    * a dir_name.ino that just includes your header and calls loop and setup
1. Try to compile, you might need to install deps for the project:

```shell
# So clangd works:
mkdir -p build && arduino-cli compile --only-compilation-database --build-path=build/ --export-binaries

# To build:
arduino-cli compile --export-binaries --build-path=build/

# As needed:
arduino-cli core install <your_board_fqbn_core>
arduino-cli lib search <some_lib>
arduino-cli lib install <some_lib>
```

## Pico (RP2040 / RP2350)

picotool and tio come with the tag, and the sdk and examples land in
`~/local/pico/`. On a Mac holding the board, `brew install picotool tio`.

Run these from the project root:

```fish
pico_build                          # board from $PICO_BOARD, default pico
pico_build pico2                    # or name it; one build dir per board
pico_flash build/pico2/blinky.uf2   # path required; pico_build prints it
pico_mon                            # serial console, or pico_mon <port>
```

Boards are `pico`, `pico_w`, `pico2` and `pico2_w`. Output lands at the top of
`build/<board>/`. Hold BOOTSEL while plugging in to get the drive. The Pico 2
has no reset button, so wiring a switch from RUN to GND avoids unplugging USB
for every flash.

Rust uses the `thumbv6m-none-eabi` target for RP2040 and
`thumbv8m.main-none-eabihf` for RP2350, with flip-link. Start a project from
`cargo generate --git https://github.com/rp-rs/rp2040-project-template`. Cargo
produces an ELF rather than a uf2, so pico_build copies it into
`build/<board>/`.

Do not write `[target.thumbv8m.main-none-eabihf]` in `.cargo/config.toml`.
Cargo cannot use a triple containing dots as a key, so it skips the section
without reporting anything and you get a 2K ELF with no entry point. Match on
cfg instead:

```toml
[target.'cfg(all(target_arch = "arm", target_os = "none"))']
rustflags = ["-C", "linker=flip-link", "-C", "link-arg=-Tlink.x"]
```

For nvim, pico_build writes a `.clangd` if the project has none. It tells
clangd which build directory to read, and which compiler to ask for include
paths.
