#!/usr/bin/env bash
# ============================================================================
#  setup-system.sh — pengaturan yang butuh sudo & tidak bisa disimpan di $HOME.
#
#  Yang dilakukan:
#    1. Tema SDDM: /var/lib/noctalia-greeter/themes/noctalia
#    2. /etc/sddm.conf.d/20-theme.conf  → Current=noctalia
#    3. Mask localsearch-3 (user)      → hilangkan indexer yang makan RAM
#    4. gsettings font monospace       → MesloLGS Nerd Font Mono 11
#    5. Pastikan /home bisa dibaca sddm? TIDAK — background di-bake ke /var/lib.
#
#  Pakai: ./system/setup-system.sh
# ============================================================================

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_SRC="$HOME/.local/share/noctalia-greeter/theme"
THEME_ROOT="/var/lib/noctalia-greeter"
THEME_DST="$THEME_ROOT/themes/noctalia"
ME="$(id -un)"

c_b=$'\033[1m'; c_g=$'\033[32m'; c_y=$'\033[33m'; c_c=$'\033[36m'; c_r=$'\033[31m'; c_0=$'\033[0m'
step() { printf '\n%s==> %s%s\n' "$c_b$c_c" "$1" "$c_0"; }
ok()   { printf '  %s✓%s %s\n' "$c_g" "$c_0" "$1"; }
warn() { printf '  %s!%s %s\n' "$c_y" "$c_0" "$1"; }
die()  { printf '  %s✗%s %s\n' "$c_r" "$c_0" "$1" >&2; exit 1; }

printf '%s\n' "${c_b}Pengaturan sistem rice${c_0}"
printf 'kamu akan diminta password sudo beberapa kali.\n'

# ---------------------------------------------------------------------------
step "1/5 Membuat direktori tema SDDM"
if [ -d "$THEME_ROOT/themes" ]; then
    ok "sudah ada: $THEME_ROOT"
else
    sudo mkdir -p "$THEME_ROOT/themes"
    sudo chown "$ME:$ME" "$THEME_ROOT" "$THEME_ROOT/themes"
    ok "dibuat: $THEME_ROOT (milik $ME, agar tidak perlu sudo lagi)"
fi

# ---------------------------------------------------------------------------
step "2/5 Menyalin tema SDDM + warna dari palette aktif"
[ -d "$THEME_SRC" ] || die "sumber tema tidak ada: $THEME_SRC (jalankan ./bootstrap.sh dulu)"
mkdir -p "$THEME_DST"
cp -f "$THEME_SRC"/* "$THEME_DST"/ 2>/dev/null || true
chmod -R a+rX "$THEME_DST"
ok "tema di $THEME_DST"

if command -v sddm-theme-sync >/dev/null 2>&1; then
    sddm-theme-sync >/dev/null && ok "theme.conf + background login disinkronkan" \
        || warn "sddm-theme-sync gagal — cek ~/.local/state/wallpaper.current"
else
    warn "sddm-theme-sync tidak di PATH — lewati sinkron palette"
fi

# ---------------------------------------------------------------------------
step "3/5 Mendaftarkan tema ke SDDM"
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/20-theme.conf >/dev/null <<EOF
[Theme]
Current=noctalia
ThemeDir=$THEME_ROOT/themes
EOF
ok "/etc/sddm.conf.d/20-theme.conf"

# ---------------------------------------------------------------------------
step "4/5 Mematikan indexer yang boros RAM"
if systemctl --user mask localsearch-3.service >/dev/null 2>&1; then
    ok "localsearch-3.service di-mask (user)"
else
    warn "gagal mask localsearch-3.service (mungkin tidak terpasang)"
fi

# ---------------------------------------------------------------------------
step "5/5 Font & preferensi GTK"
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface monospace-font-name 'MesloLGS Nerd Font Mono 11' || true
    gsettings set org.gnome.desktop.interface font-name 'Adwaita Sans 10' || true
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
    ok "gsettings diterapkan"
else
    warn "gsettings tidak ada — lewati"
fi

# ---------------------------------------------------------------------------
printf '\n%s%sSiap.%s Uji layar login tanpa reboot:\n' "$c_b" "$c_g" "$c_0"
printf '  timeout 8 sddm-greeter --test-mode --theme %s\n\n' "$THEME_DST"
printf 'Lalu logout / reboot untuk melihat hasil sebenarnya.\n'