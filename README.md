# dotfiles

Managed with GNU Stow. Each top-level folder is a package mirroring `$HOME`.

    cd ~/Development/dotfiles
    stow -t ~ niri noctalia foot fish starship btop yazi gtk thunar qt mimeapps nvim micro ir-emitter

Preview first with `stow -n -v -t ~ <packages>`.
Remove a package with `stow -D -t ~ <package>`.
