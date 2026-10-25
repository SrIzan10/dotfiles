#!/usr/bin/env bash
# Fuzzy-pick a directory and open Claude Code in it. zoxide history comes first, then any other directory under $HOME.

dir=$(
    {
        zoxide query -l 2>/dev/null
        find "$HOME" -maxdepth 4 \
            \( -path "$HOME/Development/*/*" -o -name '.*' -o -name node_modules -o -name target -o -name __pycache__ \) -prune \
            -o -type d -print 2>/dev/null
    } | awk '!seen[$0]++' |
        fzf --prompt='claude in> ' --height=100% --layout=reverse --tiebreak=index
) || exit 0

[ -n "$dir" ] && cd "$dir" && exec claude
