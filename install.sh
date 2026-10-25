#!/usr/bin/env bash
# Link this repo into $HOME with GNU Stow.
#
# For every package, existing real files in ~/.config that the package would
# replace are moved to a timestamped backup first. Generated files that are
# gitignored (noctalia.css, noctalia.kdl, fish_variables) are copied back
# afterwards so the desktop keeps working.
#
#   ./install.sh            do it
#   ./install.sh -n         dry run, changes nothing
#   ./install.sh niri fish  only these packages
set -euo pipefail
export LC_ALL=C

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME"
BACKUP="$HOME/config-backup-$(date +%Y%m%d-%H%M%S)"
DRY=0

if [[ "${1:-}" == "-n" || "${1:-}" == "--dry-run" ]]; then
    DRY=1
    shift
fi

command -v stow >/dev/null || { echo "stow is not installed" >&2; exit 1; }

if [[ $# -gt 0 ]]; then
    PACKAGES=("$@")
else
    PACKAGES=()
    for d in "$REPO"/*/; do
        PACKAGES+=("$(basename "$d")")
    done
fi

run() {
    if (( DRY )); then echo "  [dry-run] $*"; else "$@"; fi
}

is_ours() {
    # true if $1 is a symlink that resolves into this repo
    [[ -L "$1" ]] && [[ "$(readlink -f "$1")" == "$REPO"/* ]]
}

for pkg in "${PACKAGES[@]}"; do
    pkgdir="$REPO/$pkg"
    [[ -d "$pkgdir" ]] || { echo "skipping $pkg: no such package" >&2; continue; }
    echo "==> $pkg"
    moved=()

    # top-level entries the package provides, e.g. .config/niri, .config/mimeapps.list
    while IFS= read -r -d '' src; do
        rel="${src#"$pkgdir"/}"
        dest="$TARGET/$rel"

        if [[ -e "$dest" || -L "$dest" ]] && ! is_ours "$dest"; then
            echo "  backing up $rel"
            run mkdir -p "$BACKUP/$(dirname "$rel")"
            run mv "$dest" "$BACKUP/$rel"
            moved+=("$rel")
        fi
    done < <(find "$pkgdir/.config" -mindepth 1 -maxdepth 1 -print0)

    run stow -R -d "$REPO" -t "$TARGET" "$pkg"

    # restore gitignored generated files from the backup
    if (( ! DRY )); then
      for top in "${moved[@]}"; do
        [[ -e "$BACKUP/$top" ]] || continue
        while IFS= read -r -d '' f; do
            rel="${f#"$BACKUP"/}"
            [[ -e "$pkgdir/$rel" ]] && continue
            if git -C "$REPO" check-ignore -q "$pkg/$rel"; then
                echo "  restoring generated file $rel"
                mkdir -p "$pkgdir/$(dirname "$rel")"
                cp -a "$f" "$pkgdir/$rel"
            fi
        done < <(find "$BACKUP/$top" -type f -print0)
      done
    fi
done

echo
if (( DRY )); then
    echo "Dry run finished. Nothing was changed."
elif [[ -d "$BACKUP" ]]; then
    echo "Done. Originals backed up in $BACKUP"
else
    echo "Done. Nothing needed backing up."
fi
