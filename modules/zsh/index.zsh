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


# コマンドの出力を、入力した時刻の行（┌）と、終わった時刻・結果・所要時間の行（└）で囲む。
# 所要時間と終了コードはここに出すので、starship の cmd_duration と status は使わない。
# 何も入力せずに Enter したときは preexec が呼ばれないので、どちらの行も出ない。
zmodload zsh/datetime

# 時刻はミリ秒の整数で持つ。所要時間を表示した 2 つの時刻の差にして、見比べたときに計算が合うようにする。
function _command-time-now-ms() {
  local -i ms=$(( EPOCHREALTIME * 1000 ))
  REPLY=$ms
}

# %:z（+09:00）は strftime(3) に無い（GNU date の拡張）ので、%z（+0900）にコロンを足す。
function _command-time-format() {
  local date zone
  strftime -s date '%F %T' $(( $1 / 1000 ))
  strftime -s zone '%z' $(( $1 / 1000 ))
  printf -v REPLY '%s.%03d %s:%s' $date $(( $1 % 1000 )) ${zone[1,-3]} ${zone[-2,-1]}
}

function _command-time-duration() {
  local -i ms=$1
  if (( ms < 1000 )); then
    REPLY="${ms}ms"
  elif (( ms < 60000 )); then
    printf -v REPLY '%d.%03ds' $(( ms / 1000 )) $(( ms % 1000 ))
  elif (( ms < 3600000 )); then
    printf -v REPLY '%dm%02d.%03ds' $(( ms / 60000 )) $(( ms / 1000 % 60 )) $(( ms % 1000 ))
  else
    printf -v REPLY '%dh%02dm%02d.%03ds' $(( ms / 3600000 )) $(( ms / 60000 % 60 )) $(( ms / 1000 % 60 )) $(( ms % 1000 ))
  fi
}

function _command-time-preexec() {
  _command-time-now-ms
  _command_time_started=$REPLY
  _command-time-format $REPLY
  print -P "%F{8}┌ $REPLY%f"
  print
}

function _command-time-precmd() {
  local -i code=$?
  [[ -n $_command_time_started ]] || return
  local -i started=$_command_time_started
  unset _command_time_started
  _command-time-now-ms
  local -i ended=$REPLY

  # 出力が改行で終わっていないと、└ がその行の続きに出る。zsh の PROMPT_SP と同じやり方で、行の途中なら
  # 印（%）を残して次の行に移り、行頭ならそのままにする。
  print -nP '%F{8}%%%f'
  printf '%*s\r \r' $(( COLUMNS - 1 )) ''

  _command-time-duration $(( ended - started ))
  local duration=$REPLY
  _command-time-format $ended
  print
  if (( code == 0 )); then
    print -P "%F{8}└ $REPLY%f  %F{green}✓%f  %F{8}$duration%f"
  else
    print -P "%F{8}└ $REPLY%f  %F{red}✗ $code%f  %F{8}$duration%f"
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _command-time-preexec
# $? を読むので、ほかの precmd（starship）より先に呼ぶ。
precmd_functions=(_command-time-precmd $precmd_functions)
