# Rice CachyOS — catatan perubahan di mesin lama (2026-10)

Semua yang dilakukan agar mesin baru bisa direplikasi persis.

## Konsep theming
- Satu sumber warna: palet Material 3 diturunkan dari wallpaper aktif
  (`noctalia-palette` → `~/.config/noctalia/palettes/Wallpaper.json`, skema `m3-content`, mode dark).
- Noctalia merender ulang semua template: gtk3, gtk4, qt5/6, alacritty, niri,
  fuzzel, mako, swaylock, vesktop (user template di `~/.config/noctalia/templates/`).
- Radius konsisten 16, opacity 0.94 (terminal), shadow softness 24.
- Font: MesloLGS Nerd Font Mono (terminal/mono), Adwaita Sans (UI).

## niri
- `~/.config/niri/noctalia.kdl` — warna dari palet (di-include dari `config.kdl`).
- `cfg/rules.kdl` — window rule radius/opacity.
- `cfg/layout.kdl` — layout + shadow.
- `cfg/keybinds.kdl` — `Mod+Shift+M` (mem-mode hemat), `Mod+Ctrl+M` (status),
  `Mod+Shift+D` (toggle desktop widgets), `Mod+Alt+D` (edit layout desktop widgets).

## Noctalia
- `config.toml` — bar radius 16, opacity 0.55, tray widget (drawer), capsule fill surface_variant.
- `templates.toml` — daftar template aktif (builtin + user).

## SDDM (layar login)
- Tema kustom `noctalia` di `/var/lib/noctalia-greeter/themes/noctalia`:
  - `Main.qml` — jam besar (font DotGothic16), kanji 現在時刻, tanggal Jepang + Indonesia,
    kartu login radius 22, kolom sandi dengan tombol reveal, selector sesi/layout, tombol daya.
  - `theme.conf` — warna dari palet aktif (di-render `sddm-theme-sync`).
  - `wallpaper.jpg` — wallpaper aktif yang di-blur + digelapkan (di-bake, bukan dibaca dari $HOME).
  - `DotGothic16-Regular.ttf` — font retro Jepang (OFL), dimuat via FontLoader.
- `/etc/sddm.conf.d/20-theme.conf` — `Current=noctalia`, `ThemeDir=/var/lib/noctalia-greeter/themes`.
- `wallpaper-rotate` memanggil `sddm-theme-wallpaper-hook` → background login ikut wallpaper baru.

## Hemat memori (8 GB)
- `localsearch-3.service` di-mask (user).
- AnyDesk autostart dimatikan (`~/.config/autostart/*.desktop` → `Hidden=true`).
- zram zstd aktif, swappiness 150, systemd-oomd aktif (default CachyOS).
- `mem-mode` untuk mode hemat/penuh.

## Aplikasi
- Altus: `closeToTray=true`, `trayIcon=true`.
- Vesktop: close-to-tray via template CSS + pengaturan.
- GTK: adw-gtk3-dark (via template noctalia).

## Yang TIDAK ikut repo (regenerasi otomatis)
- `~/.config/noctalia/palettes/Wallpaper.json` — dibuat `noctalia-palette`.
- `~/.local/state/wallpaper.current` — dibuat `wallpaper-rotate`.
- `~/.local/state/noctalia/theme-tokens.json` — dibuat `noctalia-palette`.
- `/var/lib/noctalia-greeter/themes/noctalia/wallpaper.jpg` — dibake `sddm-theme-sync`.
- Rendered configs (gtk.css, colors.ini, dll.) — dibuat `noctalia msg templates-apply`.
