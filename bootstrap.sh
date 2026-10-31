#!/usr/bin/env bash
# ============================================================================
#  bootstrap.sh — pasang rice CachyOS (niri + Noctalia) dari repo ini.
#
#  Pakai:
#    ./bootstrap.sh                 # salin file ke $HOME (aman, ada backup)
#    ./bootstrap.sh --link          # symlink ke repo (enak buat ngedit dotfiles)
#    ./bootstrap.sh --dry-run       # lihat apa yang bakal dilakukan
#    ./bootstrap.sh --only home     # hanya file $HOME (lewati langkah sistem)
#
#  Langkah sistem (butuh sudo) dijalankan terpisah:
#    ./system/setup-system.sh
# ============================================================================

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="copy"
DRY=0
DO_HOME=1
DO_SYSTEM=0
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/.dotfiles-backup/$STAMP"

c_reset=$'\033[0m'; c_b=$'\033[1m'; c_g=$'\033[32m'; c_y=$'\033[33m'; c_c=$'\033[36m'; c_r=$'\033[31m'
step() { printf '\n%s==> %s%s\n' "$c_b$c_c" "$1" "$c_reset"; }
ok()   { printf '  %s✓%s %s\n' "$c_g" "$c_reset" "$1"; }
warn() { printf '  %s!%s %s\n' "$c_y" "$c_reset" "$1"; }
die()  { printf '  %s✗%s %s\n' "$c_r" "$c_reset" "$1" >&2; exit 1; }

for arg in "$@"; do
    case "$arg" in
        --link)     MODE="link" ;;
        --copy)     MODE="copy" ;;
        --dry-run)  DRY=1 ;;
        --only)     DO_HOME=1; DO_SYSTEM=0 ;;
        --system)   DO_HOME=0; DO_SYSTEM=1 ;;
        -h|--help)  sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)          die "argumen tidak dikenal: $arg" ;;
    esac
done

printf '%s\n' "${c_b}Rice CachyOS — bootstrap${c_reset}"
printf 'repo    : %s\n' "$REPO"
printf 'mode    : %s%s\n' "$MODE" "$([ "$DRY" = 1 ] && echo ' (dry-run)')"

# ---------------------------------------------------------------------------
# 1. File di $HOME
# ---------------------------------------------------------------------------
if [ "$DO_HOME" = 1 ]; then
    step "Memasang file konfigurasi ke \$HOME"

    backup() {
        local dest="$1"
        [ -e "$dest" ] || [ -L "$dest" ] || return 0
        local rel="${dest#$HOME/}"
        local target="$BACKUP_DIR/$rel"
        mkdir -p "$(dirname "$target")"
        cp -a "$dest" "$target"
        warn "backup: ~/$rel"
    }

    while IFS= read -r -d '' src; do
        rel="${src#$REPO/home/}"
        dest="$HOME/$rel"

        # symlink yang sudah benar → lewati
        if [ "$MODE" = "link" ] && [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
            continue
        fi
        # file identik → lewati (mode copy)
        if [ "$MODE" = "copy" ] && [ -f "$dest" ] && cmp -s "$src" "$dest"; then
            continue
        fi

        if [ "$DRY" = 1 ]; then
            printf '  %s %s\n' "$([ "$MODE" = link ] && echo 'link' || echo 'copy')" "~/$rel"
            continue
        fi

        mkdir -p "$(dirname "$dest")"
        backup "$dest"

        if [ "$MODE" = "link" ]; then
            rm -rf "$dest"
            ln -s "$src" "$dest"
        else
            rm -rf "$dest"
            cp -a "$src" "$dest"
        fi
        ok "~/$rel"
    done < <(find "$REPO/home" -type f -print0 | sort -z)

    # skrip di ~/.local/bin harus executable
    if [ "$DRY" = 0 ]; then
        chmod +x "$HOME"/.local/bin/* 2>/dev/null || true
    fi

    if [ -d "$BACKUP_DIR" ]; then
        printf '\n  backup lama disimpan di: %s\n' "$BACKUP_DIR"
    fi
fi

# ---------------------------------------------------------------------------
# 2. Wallpaper awal + palette
# ---------------------------------------------------------------------------
if [ "$DO_HOME" = 1 ] && [ "$DRY" = 0 ]; then
    step "Menyiapkan wallpaper & palette"

    state_dir="${XDG_STATE_HOME:-$HOME/.local/state}"
    mkdir -p "$state_dir"

    if [ -s "$state_dir/wallpaper.current" ] && [ -f "$(head -1 "$state_dir/wallpaper.current")" ]; then
        ok "wallpaper aktif sudah ada: $(head -1 "$state_dir/wallpaper.current")"
    else
        first="$(find "$HOME/Pictures/Wallpaper" -maxdepth 1 -type f \
                  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
                  2>/dev/null | sort | head -1)"
        if [ -n "$first" ]; then
            printf '%s\n' "$first" > "$state_dir/wallpaper.current"
            ok "wallpaper awal: $first"
        else
            warn "tidak ada wallpaper di ~/Pictures/Wallpaper — taruh minimal 1 gambar di sana"
        fi
    fi

    if command -v noctalia-palette >/dev/null 2>&1; then
        noctalia-palette >/dev/null 2>&1 && ok "palette Wallpaper.json dibuat" \
            || warn "noctalia-palette gagal (jalankan manual setelah wallpaper ada)"
    else
        warn "noctalia-palette tidak ada di PATH (~/.local/bin)"
    fi

    # background login awal
    if command -v sddm-theme-sync >/dev/null 2>&1 && [ -d /var/lib/noctalia-greeter/themes ]; then
        sddm-theme-sync >/dev/null 2>&1 && ok "tema SDDM disinkronkan" \
            || warn "sddm-theme-sync gagal (jalankan ./system/setup-system.sh dulu)"
    fi
fi

# ---------------------------------------------------------------------------
# 3. Ringkasan
# ---------------------------------------------------------------------------
printf '\n%s%sSelesai.%s\n' "$c_b" "$c_g" "$c_reset"
cat <<'EOF'

Langkah berikutnya:
  1. Pasang paket yang belum ada:
       ./packages/install-packages.sh
  2. Terapkan pengaturan sistem (SDDM, gsettings, mask tracker) — butuh sudo:
       ./system/setup-system.sh
  3. Logout lalu login ulang (atau reboot) supaya niri + Noctalia memuat config baru.
EOF
