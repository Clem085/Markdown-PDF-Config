#!/usr/bin/env sh
# Install Markdown PDF Plus themes for the current user (Linux).
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
DEST_DIR="${HOME:?HOME must be set}/.config/Code/markdown-themes"

find_theme() {
    name=$1
    # The repo can have a flat or nested layout. Ignore Git internals.
    matches=$(find "$SCRIPT_DIR" -type d -name .git -prune -o -type f -name "$name" -print)
    if [ -z "$matches" ]; then
        printf 'ERROR: Could not find %s inside %s\n' "$name" "$SCRIPT_DIR" >&2
        return 1
    fi
    # Refuse ambiguous files rather than silently install the wrong theme.
    count=$(printf '%s\n' "$matches" | wc -l | tr -d ' ')
    if [ "$count" -ne 1 ]; then
        printf 'ERROR: Found %s copies of %s; leave one source copy in the repository.\n%s\n' "$count" "$name" "$matches" >&2
        return 1
    fi
    printf '%s\n' "$matches"
}

LIGHT_SRC=$(find_theme pdf-light.css) || exit 1
DARK_SRC=$(find_theme pdf-dark.css) || exit 1

mkdir -p "$DEST_DIR"
install_theme() {
    src=$1
    file=$2
    dest="$DEST_DIR/$file"
    if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
        printf 'Unchanged: %s\n' "$dest"
        return
    fi
    if [ -e "$dest" ]; then
        if [ ! -f "$dest" ]; then
            printf 'ERROR: Destination exists and is not a regular file: %s\n' "$dest" >&2
            exit 1
        fi
        timestamp=$(date '+%Y%m%d-%H%M%S')
        backup="${dest}.bak-${timestamp}"
        n=1
        while [ -e "$backup" ]; do
            backup="${dest}.bak-${timestamp}-${n}"
            n=$((n + 1))
        done
        cp -p "$dest" "$backup"
        printf 'Backup: %s\n' "$backup"
    fi
    cp "$src" "$dest"
    printf 'Installed: %s\n' "$dest"
}

install_theme "$LIGHT_SRC" pdf-light.css
install_theme "$DARK_SRC" pdf-dark.css
printf '\nDone. Add the VS Code User settings shown in README.md (if not already configured).\n'
printf 'Light CSSPath: ~/.config/Code/markdown-themes/pdf-light.css\n'
printf 'Dark CSSPath:  ~/.config/Code/markdown-themes/pdf-dark.css\n'
