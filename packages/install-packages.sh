#!/usr/bin/env bash
# ============================================================================
#  install-packages.sh — pasang paket yang dipakai rice ini.
#
#  Dua daftar:
#    packages/rice.txt      → paket minimal untuk rice (repo resmi)
#    packages/aur.txt       → paket dari AUR (butuh paru/yay)
#    packages/explicit.txt  → SEMUA paket eksplisit di mesin lama (referensi)
#
#  Pakai:
#    ./packages/install-packages.sh            # rice.txt + aur.txt
#    ./packages/install-packages.sh --all      # explicit.txt juga
#    ./packages/install-packages.sh --dry-run
# ============================================================================

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALL=0
DRY=0

for arg in "$@"; do
    case "$arg" in
        --all)     ALL=1 ;;
        --dry-run) DRY=1 ;;
        -h|--help) sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "argumen tidak dikenal: $arg" >&2; exit 1 ;;
    esac
done

mapfile -t RICE < <(grep -vE '^\s*(#|$)' "$HERE/rice.txt")
mapfile -t AUR  < <(grep -vE '^\s*(#|$)' "$HERE/aur.txt")

echo "==> Paket rice (${#RICE[@]})"
printf '    %s\n' "${RICE[@]}"

if [ "$DRY" = 1 ]; then
    echo "==> dry-run: tidak memasang apa pun"
    exit 0
fi

sudo pacman -S --needed --noconfirm "${RICE[@]}"

if [ "${#AUR[@]}" -gt 0 ]; then
    if command -v paru >/dev/null 2>&1; then
        AURHELPER=paru
    elif command -v yay >/dev/null 2>&1; then
        AURHELPER=yay
    else
        echo "!! paru/yay tidak ada — lewati paket AUR:" >&2
        printf '   %s\n' "${AUR[@]}" >&2
        AURHELPER=""
    fi

    if [ -n "$AURHELPER" ]; then
        echo "==> Paket AUR (${#AUR[@]}) via $AURHELPER"
        "$AURHELPER" -S --needed --noconfirm "${AUR[@]}"
    fi
fi

if [ "$ALL" = 1 ]; then
    echo "==> Semua paket eksplisit dari mesin lama"
    mapfile -t EXPLICIT < <(grep -vE '^\s*(#|$)' "$HERE/explicit.txt")
    sudo pacman -S --needed --noconfirm "${EXPLICIT[@]}" || true
fi

echo "==> selesai"
