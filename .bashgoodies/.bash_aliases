alias hglisthead="hg status --rev p4base"
alias hglistlast="hg status --rev .^"

alias arduino_init="mkdir -p build && arduino-cli compile --only-compilation-database --build-path=build/ --export-binaries"
alias arduino_build="arduino-cli compile --export-binaries --build-path=build/"
alias arduino_up="arduino-cli upload --input-dir=build/"
alias arduino_buildup="arduino_build && arduino_up"
