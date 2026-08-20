# yazi (TUI ファイルマネージャ)。helix と組ませる前提で置いている ── helix には
# ファイルツリーが無く、開いていないファイルを「眺めながら選ぶ」手段が弱いので、
# その穴を埋める役。単体で使うときは zsh 関数 `y` で開き、抜けた先へシェルごと cd する。
{...}: let
  # yazi が選択結果を書き出す先。helix 側は同じファイルを読んで :open する。
  # 公式レシピは /tmp の固定パスだが、他人と共用のマシンで衝突しない位置へ移してある。
  chooserDir = "$HOME/.cache/helix";
  chooserFile = "${chooserDir}/yazi-chooser";
in {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    # opener は既定のまま $EDITOR に任せる。EDITOR を hx に固定するのは modules/helix.nix
    # 側で、ここに hx と書くと「エディタは何か」の答えが二箇所に増える。
    settings.mgr.show_hidden = true; # helix の file-picker.hidden = false と揃える
  };

  # helix からの入口。yazi 公式の Helix 連携レシピ
  # (https://yazi-rs.github.io/docs/tips) をなぞっている。
  #
  # 肝は :insert-output が helix の端末をそのまま子プロセスへ貸すこと。wezterm のペイン
  # 分割に頼らないので、ssh 先（kali / claude コンテナ）の helix でも同じキーで動く
  # ── 端末を借りられない hunk 側 (modules/hunk.nix の C-g) とはそこが違う。
  #
  # 前後の :sh は後始末:
  #   - 先頭の rm は前回の選択結果を消す（残っていると選ばずに抜けたとき古いファイルが開く）
  #   - printf は yazi が去ったあとの代替画面・bracketed paste を helix 用に戻す
  #   - :redraw と mouse の入れ直しで描画とマウス設定を初期化する
  programs.helix.settings.keys.normal."C-y" = [
    '':sh mkdir -p "${chooserDir}" && rm -f "${chooserFile}"''
    '':insert-output yazi "%{buffer_name}" --chooser-file="${chooserFile}"''
    '':sh printf '\033[?1049h\033[?2004h' > /dev/tty''
    '':open %sh{cat "${chooserFile}"}''
    ":redraw"
    ":set mouse false"
    ":set mouse true"
  ];
}
