# ctrl + rでコマンド履歴
function select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^r' select-history


# ctrl + rでgitのブランチをインタラクティブに変更
function select-git-switch() {
  target_br=$(
    git branch |
      fzf --exit-0 --layout=reverse --info=hidden --no-multi --preview-window="right,65%" --prompt="CHECKOUT BRANCH > " --preview="echo {} | tr -d ' *' | xargs git log --graph --oneline --color=always" |
      head -n 1 |
      perl -pe "s/\s//g; s/\*//g; s/remotes\/origin\///g"
  )
  if [ -n "$target_br" ]; then
    BUFFER="git switch $target_br"
    zle accept-line
  fi
}
zle -N select-git-switch
bindkey "^g" select-git-switch


chpwd() {
  if [[ $(pwd) != $HOME ]]; then;
    ls
  fi
}

function select-nix-switch() {
  nixcmd=$(
    nix flake show --json | 
      jq -r --arg sys $(nix eval --impure --raw --expr 'builtins.currentSystem') '.packages.[$sys] | keys | .[]' | 
      fzf --exit-0 --layout=reverse --info=hidden --no-multi --preview-window="right,65%" --prompt="nix run .# > " 
  )
  if [ -n "$nixcmd" ]; then
    BUFFER="nix run .#$nixcmd"
    zle accept-line
  fi
}
zle -N select-nix-switch
bindkey "^n" select-nix-switch
