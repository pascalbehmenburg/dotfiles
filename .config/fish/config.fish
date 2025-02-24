source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
end

alias find "fd"
alias ls "eza -l --git-repos --no-user"
alias grep "rg"
alias ff "fzf"

zoxide init fish | source
fish_add_path $HOME/.local/bin

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
