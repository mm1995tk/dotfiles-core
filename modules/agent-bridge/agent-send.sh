# helix で見ている位置を、走っているエージェント（Claude Code など）の入力欄へ置く。
# 呼び出し元は dotfiles/modules/agent-bridge/default.nix が定義する helix のキー。
#
# 送るのは選択したテキストそのものではなく「リポジトリ相対のパス:行」。エージェントは
# 自分でファイルを読めるので、プロンプトが短く済むうえ、別ホストの herdr に送っても
# 意味が通る（絶対パスだと送り先のコンテナには存在しないパスになる）。
#
# 使い方: agent-send <file> <start-line> [end-line]

if [ $# -lt 2 ]; then
  echo "usage: agent-send <file> <start-line> [end-line]"
  exit 2
fi

file=$1
start=$2
end=${3:-$2}

# 別ホストの herdr へ送るときだけ AGENT_SEND_HOST を設定する（例: Mac の helix から
# claude コンテナのエージェントへ）。herdr の socket API はローカル固定で remote 指定を
# 持たないので、ssh で向こう側でコマンドごと実行するしかない。
herdr_() {
  if [ -n "${AGENT_SEND_HOST:-}" ]; then
    local remote_cmd=herdr
    local arg
    for arg in "$@"; do
      remote_cmd="$remote_cmd $(printf '%q' "$arg")"
    done
    ssh -o BatchMode=yes "$AGENT_SEND_HOST" "$remote_cmd"
  else
    herdr "$@"
  fi
}

dir=$(cd "$(dirname "$file")" && pwd)
abs="$dir/$(basename "$file")"
root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true)

ref=$abs
if [ -n "$root" ]; then
  ref=${abs#"$root/"}
fi

if [ "$start" = "$end" ]; then
  ref="$ref:$start"
else
  ref="$ref:$start-$end"
fi

# 同じリポジトリで動いているエージェントを優先し、見つからなければ最初の 1 つに送る。
# 候補が複数あるときに黙って別のエージェントへ送るのを避けるための順序付け。
agents=$(herdr_ agent list 2>/dev/null || true)
pane=$(
  printf '%s' "$agents" | jq -r --arg root "${root:-}" '
    (.result.agents // []) as $a
    | (($a | map(select(.cwd == $root))) + $a)
    | (.[0] // {})
    | .pane_id // empty
  ' 2>/dev/null || true
)

if [ -z "$pane" ]; then
  echo "agent-send: 送り先が見つからない（herdr の中でエージェントを動かしているか確認する）"
  exit 1
fi

# 送信はしない。参照を置くだけにして、続きの文章は本人に書かせる。
herdr_ pane send-text "$pane" "@$ref "

# フォーカス移動は「あると嬉しい」程度なので、失敗しても送信の成否には影響させない。
herdr_ agent focus "$pane" >/dev/null 2>&1 || true
