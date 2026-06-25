if not set -q __fish_theme_saved
    fish_config theme choose catppuccin-mocha
    fish_config theme save
    set -U __fish_theme_saved 1
end
