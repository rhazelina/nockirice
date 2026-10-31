# rice — CachyOS · niri · Noctalia

Dotfiles untuk setup CachyOS dengan **niri** (compositor Wayland) + **Noctalia** (shell/bar),
dengan satu sumber warna: palet Material yang diturunkan dari wallpaper aktif.

```
┌────────────────────────────────────────────────────────────────┐
│  wallpaper aktif (~/Pictures/Wallpaper)                        │
│        │  noctalia-palette                                     │
│        ▼                                                       │
│  ~/.config/noctalia/palettes/Wallpaper.json                    │
│        │  noctalia msg templates-apply                         │
│        ▼                                                       │
│  gtk3 · gtk4 · qt5/6 · alacritty · niri · mako · fuzzel ·      │
│  swaylock · vesktop                                            │
│        │                                                       │
│        └── sddm-theme-sync ──► layar login (SDDM) ikut warna   │
└────────────────────────────────────────────────────────────────┘
```

## Isi repo

| Path | Isi |
|---|---|
| `home/.config/` | niri, noctalia, alacritty, fuzzel, mako, swaylock, gtk, qt, fish, Altus, btop |
| `home/.local/bin/` | skrip rice: `noctalia-palette`, `wallpaper-rotate`, `mem-mode`, `sddm-theme-sync`, dll. |
| `home/.local/share/noctalia-greeter/theme/` | tema SDDM kustom (QML + font DotGothic16) |
| `packages/` | daftar paket + skrip pemasangan |
| `system/` | pengaturan yang butuh sudo (SDDM, mask indexer, gsettings) |
| `docs/CHANGES.md` | catatan apa saja yang diubah di mesin lama |

## Cara pakai di mesin baru (CachyOS / Arch)

```bash
# 0. clone repo ini
git clone <url-repo> ~/.dotfiles && cd ~/.dotfiles

# 1. pasang paket (repo resmi + AUR)
./packages/install-packages.sh

# 2. pasang file konfigurasi ke $HOME
#    default: salin (aman). pakai --link kalau mau edit langsung dari repo.
./bootstrap.sh

# 3. pengaturan sistem — butuh sudo
./system/setup-system.sh

# 4. taruh wallpaper di ~/Pictures/Wallpaper (minimal 1 gambar),
#    lalu regenerate palette:
noctalia-palette

# 5. logout / reboot
```

### Opsi bootstrap

```bash
./bootstrap.sh --dry-run     # lihat dulu apa yang bakal diubah
./bootstrap.sh --link        # symlink (edit dotfiles = edit repo)
./bootstrap.sh --copy        # salin (default)
./bootstrap.sh --system      # hanya langkah sistem
```

## Skrip penting

| Skrip | Fungsi |
|---|---|
| `noctalia-palette` | turunkan palet Material dari wallpaper aktif → render semua template |
| `wallpaper-rotate` | ganti wallpaper (--next/--prev/--random) + regenerate palette + update lock screen & background login |
| `sddm-theme-sync` | sinkron tema SDDM (background blur + theme.conf dari palet) |
| `mem-mode` | hemat / penuh / status — mode memori (keybind `Mod+Shift+M`, `Mod+Ctrl+M`) |
| `wallpaper-picker` | pilih wallpaper via fuzzel |

## Catatan

- **SDDM**: tema di-deploy ke `/var/lib/noctalia-greeter/themes/noctalia` (world-readable),
  karena `$HOME` mode 700 tidak bisa dibaca user `sddm`. Background login di-bake
  (blur + dim) oleh `sddm-theme-sync`, bukan dibaca langsung dari `$HOME`.
- **Font**: `MesloLGS Nerd Font Mono` dari paket `ttf-meslo-nerd`;
  `DotGothic16` di-bundle langsung di folder tema (FontLoader QML, tidak perlu install).
- **Indexer**: `localsearch-3.service` di-mask untuk hemat RAM.
- **Altus & Vesktop**: dikonfigurasi close-to-tray, bukan exit.
- Backup bootstrap lama tersimpan di `~/.dotfiles-backup/<timestamp>/`.
