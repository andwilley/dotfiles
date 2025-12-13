function sesh
set -l target $argv[1]
if test -z "$target"
    set target "sesh"
end
tmux new-session -A -s $target
end
