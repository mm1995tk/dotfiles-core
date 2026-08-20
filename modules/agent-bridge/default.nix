# helix から、走っている AI エージェント（Claude Code）へ「いまどこを見ているか」を渡す橋。
#
# VS Code の拡張のような自動追従はできない ── helix にはプラグイン API もイベントフックも
# 無く、外部へ状態を通知する手段が無いため。代わりに「キーを押した瞬間の位置」を送る。
# 押した時点のスナップショットしか渡らない代わりに、何が共有されたかが曖昧にならない。
#
# 経路は herdr（エージェントのペインを socket API で操作できる）に寄せてある。wezterm の
# ペイン操作でも同じことはできるが、それだと wezterm の無い ssh 先（kali / claude コンテナ）
# で使えないうえ、「どのペインで claude が動いているか」を推測する必要がある。herdr は
# エージェントを一級の概念として持っているので、宛先を推測せずに引ける。
{pkgs, ...}: let
  agentSend = pkgs.writeShellApplication {
    name = "agent-send";
    # herdr は runtimeInputs に入れない。コンテナ側の herdr は nixpkgs ではなく
    # /usr/local/bin にあり（containers/services/claude/Dockerfile）、ここで nixpkgs 版を
    # PATH の先頭に差し込むと、クライアントとサーバのバージョンがずれる。
    runtimeInputs = [pkgs.git pkgs.jq];
    text = builtins.readFile ./agent-send.sh;
  };

  # 保存してから送るのは、エージェントがディスクを読むから。未保存だと送った行と
  # 実際に読まれる内容がずれる（VS Code の連携はエディタ上のバッファを渡すのでずれない）。
  sendKey = [
    ":write"
    '':sh agent-send "%{buffer_name}" %{selection_line_start} %{selection_line_end}''
  ];
in {
  home.packages = [agentSend];

  # 選択範囲があれば `path:12-30`、無ければ `path:34` になる。select モードにも同じキーを
  # 置くのは、helix では選択が normal / select どちらのモードでも成立するため。
  programs.helix.settings.keys.normal."C-n" = sendKey;
  programs.helix.settings.keys.select."C-n" = sendKey;
}
