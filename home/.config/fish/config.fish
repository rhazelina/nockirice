source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# kilo
fish_add_path /home/fichela/.kilo/bin

# FixWall
fish_add_path ~/.local/bin


# Added by Antigravity CLI installer
set -gx PATH "/home/fichela/.local/bin" $PATH
