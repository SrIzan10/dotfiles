#!/usr/bin/env bash
# Open foot in the directory most recently cd'd into from any fish session (see config.fish).

last=$(cat "${XDG_STATE_HOME:-$HOME/.local/state}/last-cwd" 2>/dev/null)

if [ -d "$last" ]; then
    exec foot --working-directory="$last" "$@"
fi
exec foot "$@"
