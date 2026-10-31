#!/usr/bin/env bash
# ============================================================================
#  install.sh — instalasi otomatis penuh rice CachyOS (niri + Noctalia).
#
#  Satu perintah, jalan dari awal sampai siap reboot:
#     ./install.sh
#
#  Yang dilakukan, berurutan:
#     1. cek prasyarat (Arch-based, bukan root, ada network)
#     2. pasang paket repo resmi (packages/rice.txt)
#     3. pasang paket AUR kalau paru/yay tersedia (packages/aur.txt)
#     4. salin dotfiles ke $HOME (bootstrap, dengan backup)
#     5. pengaturan sistem via sudo (SDDM, mask indexer, gsettings)
#     6. bangun palette dari wallpaper + render semua template
#     7. verifikasi: tema SDDM, config niri, font, skrip executable
#
#  Opsi:
#     --link        symlink dotfiles (bukan salin)
#     --no-packages lewati pemasangan paket (mesin sudah lengkap)
#     --no-system   lewati langkah sudo
#     --dry-run     tampilkan rencana tanpa mengubah apa pun
#     --yes         jangan minta konfirmasi
# ============================================================================

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="copy"
DO_PACKAGES=1
DO_SYSTEM=1
DRY=0
ASSUME_YES=0

c_b=$'\033[1m'; c_g=$'\033[32m'; c_y=$'\033[33m'; c_c=$'\033[36m'; c_r=$'\033[31m'; c_0=$'\033[0m'
step() { printf '\n%s%s━━ %s%s\n' "$c_b" "$c_c" "$1" "$c_0"; }
ok()   { printf '   %s✓%s %s\n' "$c_g" "$c_0" "$1"; }
warn() { printf '   %s!%s %s\n' "$c_y" "$c_0" "$1"; }
die()  { printf '   %s✗%s %s\n' "$c_r" "$c_0" "$1" >&2; exit 1; }

for arg in "$@"; do
    case "$arg" in
        --link)        MODE="link" ;;
        --no-packages) DO_PACKAGES=0 ;;
        --no-system)   DO_SYSTEM=0 ;;
        --dry-run)     DRY=1 ;;
        --yes|-y)      ASSUME_YES=1 ;;
        -h|--help)     sed -n '2,26p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)             die "argumen tidak dikenal: $arg" ;;
    esac
done

confirm() {
    [ "$ASSUME_YES" = 1 ] && return 0
    printf '   %s?%s %s [Y/n] ' "$c_y" "$c_0" "$1"
    read -r ans
    [[ -z "${ans:-}" || "${ans,,}" == "y" || "${ans,,}" == "ya" ]]
}

printf '%s\n' "${c_b}╭──────────────────────────────────────────────╮${c_0}"
printf '%s\n' "${c_b}│  rice CachyOS · niri + Noctalia · installer   │${c_0}"
printf '%s\n' "${c_b}╰──────────────────────────────────────────────╯${c_0}"

# ---------------------------------------------------------------------------
step "1/7  Memeriksa prasyarat"

[ "$(id -u)" -eq 0 ] && die "jangan jalankan sebagai root — jalankan sebagai user biasa (sudo akan diminta sendiri)"
ok "bukan root"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "${ID:-}${ID_LIKE:-}" in
        *arch*|*cachyos*) ok "distro: ${PRETTY_NAME:-Arch-based}" ;;
        *) warn "bukan Arch/CachyOS (${PRETTY_NAME:-?}) — paket mungkin gagal, lanjutkan dengan hati-hati" ;;
    esac
fi

command -v pacman >/dev/null 2>&1 || die "pacman tidak ditemukan"
ok "pacman tersedia"

[ -d "$REPO/home" ] || die "struktur repo rusak: $REPO/home tidak ada"
ok "repo lengkap ($(find "$REPO/home" -type f | wc -l) file)"

# sesi Wayland aktif? (tidak wajib, hanya info)
[ -n "${NIRI_SOCKET:-}" ] && ok "sedang di sesi niri (bisa tes langsung setelah selesai)" \
                          || warn "tidak terdeteksi sesi niri — hasil dilihat setelah reboot"

if [ "$DRY" = 1 ]; then
    printf '\n   %s(dry-run: tidak ada yang diubah)%s\n' "$c_y" "$c_0"
fi

# ---------------------------------------------------------------------------
step "2/7  Paket dari repo resmi"

if [ "$DO_PACKAGES" = 0 ]; then
    warn "dilewati (--no-packages)"
elif [ "$DRY" = 1 ]; then
    grep -vE '^\s*(#|$)' "$REPO/packages/rice.txt" | sed 's/^/     /'
else
    mapfile -t RICE < <(grep -vE '^\s*(#|$)' "$REPO/packages/rice.txt")
    printf '   %s paket: %s\n' "${#RICE[@]}" "${RICE[*]}"
    if confirm "pasang paket di atas?"; then
        sudo pacman -S --needed --noconfirm "${RICE[@]}"
        ok "paket repo terpasang"
    else
        warn "dilewati oleh pengguna"
    fi
fi

# ---------------------------------------------------------------------------
step "3/7  Paket AUR"

AUR_FILE="$REPO/packages/aur.txt"
if [ "$DO_PACKAGES" = 0 ] || [ ! -s "$AUR_FILE" ]; then
    warn "tidak ada paket AUR / dilewati"
elif [ "$DRY" = 1 ]; then
    grep -vE '^\s*(#|$)' "$AUR_FILE" | sed 's/^/     /'
else
    HELPER=""
    command -v paru >/dev/null 2>&1 && HELPER=paru
    [ -z "$HELPER" ] && command -v yay >/dev/null 2>&1 && HELPER=yay

    if [ -z "$HELPER" ]; then
        warn "paru/yay tidak ada — paket AUR dilewati:"
        grep -vE '^\s*(#|$)' "$AUR_FILE" | sed 's/^/     /'
    else
        mapfile -t AUR < <(grep -vE '^\s*(#|$)' "$AUR_FILE")
        printf '   %s paket via %s: %s\n' "${#AUR[@]}" "$HELPER" "${AUR[*]}"
        if confirm "pasang paket AUR di atas?"; then
            "$HELPER" -S --needed --noconfirm "${AUR[@]}" || warn "sebagian paket AUR gagal (bisa dilewati)"
            ok "paket AUR selesai"
        else
            warn "dilewati oleh pengguna"
        fi
    fi
fi

# ---------------------------------------------------------------------------
step "4/7  Memasang dotfiles ke \$HOME"

if [ "$DRY" = 1 ]; then
    "$REPO/bootstrap.sh" --dry-run --only 2>&1 | grep -E '^\s+(copy|link)' || true
else
    "$REPO/bootstrap.sh" "--$MODE" --only
    ok "dotfiles terpasang (mode: $MODE)"
fi

# ---------------------------------------------------------------------------
step "5/7  Pengaturan sistem (sudo)"

if [ "$DO_SYSTEM" = 0 ]; then
    warn "dilewati (--no-system)"
elif [ "$DRY" = 1 ]; then
    printf '     akan membuat /var/lib/noctalia-greeter, menulis /etc/sddm.conf.d/20-theme.conf,\n'
    printf '     mask localsearch-3, set gsettings font\n'
else
    if confirm "terapkan pengaturan sistem (butuh sudo)?"; then
        "$REPO/system/setup-system.sh" < /dev/null || warn "sebagian langkah sistem gagal — cek manual"
        ok "pengaturan sistem selesai"
    else
        warn "dilewati oleh pengguna"
    fi
fi

# ---------------------------------------------------------------------------
step "6/7  Palette dari wallpaper + render template"

if [ "$DRY" = 1 ]; then
    printf '     noctalia-palette && sddm-theme-sync\n'
else
    if [ ! -s "$HOME/.local/state/wallpaper.current" ]; then
        warn "belum ada wallpaper aktif — taruh gambar di ~/Pictures/Wallpaper lalu jalankan:"
        printf '     wallpaper-rotate\n'
    fi
    if command -v noctalia-palette >/dev/null 2>&1; then
        PATH="$HOME/.local/bin:$PATH" noctalia-palette >/dev/null 2>&1 \
            && ok "palette dibuat + semua template dirender" \
            || warn "noctalia-palette gagal (tidak ada wallpaper?)"
    else
        warn "noctalia-palette tidak di PATH"
    fi
fi

# ---------------------------------------------------------------------------
step "7/7  Verifikasi"

fail=0
check() { # label, command
    if eval "$2" >/dev/null 2>&1; then ok "$1"; else warn "$1 — GAGAL"; fail=$((fail+1)); fi
}

if [ "$DRY" = 0 ]; then
    check "config niri ada"            "[ -f $HOME/.config/niri/config.kdl ]"
    check "config Noctalia ada"        "[ -f $HOME/.config/noctalia/config.toml ]"
    check "palette Wallpaper.json"      "[ -s $HOME/.config/noctalia/palettes/Wallpaper.json ]"
    check "skrip ~/.local/bin executable" "[ -x $HOME/.local/bin/noctalia-palette ]"
    check "font MesloLGS terpasang"    "fc-list | grep -qi 'MesloLGS Nerd Font Mono'"
    check "tema SDDM ter-deploy"       "[ -f /var/lib/noctalia-greeter/themes/noctalia/Main.qml ]"
    check "SDDM pakai tema noctalia"   "grep -q 'Current=noctalia' /etc/sddm.conf.d/20-theme.conf"
else
    warn "dry-run: verifikasi dilewati"
fi

# ---------------------------------------------------------------------------
printf '\n%s%s━━ Selesai ━━%s\n' "$c_b" "$c_g" "$c_0"

if [ "$DRY" = 1 ]; then
    printf '  Ini baru simulasi. Jalankan tanpa %s--dry-run%s untuk benar-benar memasang.\n\n' "$c_c" "$c_0"
    exit 0
fi

if [ "${fail:-0}" -gt 0 ]; then
    printf '  %s%s%s Ada %s pemeriksaan yang gagal — lihat pesan di atas.\n\n' "$c_b" "$c_y" "$c_0" "$fail"
else
    printf '  Semua pemeriksaan lolos.\n\n'
fi

cat <<EOF
  Langkah berikutnya:
    1. tes layar login tanpa reboot:
         timeout 8 sddm-greeter --test-mode --theme /var/lib/noctalia-greeter/themes/noctalia
    2. logout / reboot untuk melihat hasil sebenarnya
    3. ganti wallpaper kapan saja:
         wallpaper-rotate --next

  Keybind yang perlu diingat:
     Mod+Shift+M  → mode hemat memori
     Mod+Ctrl+M   → status memori
     Mod+Space    → launcher (fuzzel)

EOF
