# zsh-syntax-highlighting 0.8.0 では、パスの通ったコマンド（第1語）は arg0 の
# fg=green で描かれる。淡い緑のテーマだと本文の白と明度・彩度が近くなり
# 「実行できるコマンドかどうか」が一目で分からないため、色相の離れた紫に
# する。テーマの magenta（iris #c4a7e7）そのままだと淡いので、同じ色相で
# 彩度を上げ明度を下げた値を直接指定する。command/builtin/alias は既定値が
# 無く arg0 にフォールバックするので、ここだけ上書きすれば全種類に効く。
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#a986d9,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a986d9,bold,underline'


function select-history() {
  local selected=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
  if [ -n "$selected" ]; then
    BUFFER=$selected
    CURSOR=$#BUFFER
  fi
  zle reset-prompt
}
zle -N select-history
bindkey '^r' select-history


# ctrl + gでgitのブランチをインタラクティブに変更
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
