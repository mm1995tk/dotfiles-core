# hunk (差分ビューア)。差分を読む場所を1つに寄せるモジュールで、git のページャと
# helix / yazi からの入口をまとめて持つ。
{pkgs, ...}: let
  # 端末 (wezterm の "GitHub Dark") と helix の github_dark に色を揃える。
  theme = "github-dark";
in {
  home.packages = [pkgs.hunk];

  programs.git.settings = {
    # ページャは stdout が端末のときしか起動しないので、パイプ越しや非対話の実行
    # （Claude Code の Bash など）の出力は素のままで変わらない。
    pager.diff = "hunk pager --theme ${theme}";
    pager.show = "hunk pager --theme ${theme}";
    # log は素のページャのまま。本体はコミット一覧であって差分ではないため
    # （差分になるのは -p を付けたときだけ）。

    diff.tool = "hunk";
    difftool.hunk.cmd = ''hunk difftool "$LOCAL" "$REMOTE"'';
    difftool.prompt = false;
  };

  # yazi: hover しているファイルの差分だけを見る。--block で yazi が副画面へ退避して
  # 端末を明け渡すので、ペイン分割の要らない（＝ssh 先でも動く）経路になる。
  programs.yazi.keymap.mgr.prepend_keymap = [
    {
      on = "<C-g>";
      run = "shell --block -- hunk diff --theme ${theme} -- %h";
      desc = "hunk でこのファイルの差分を見る";
    }
  ];

  # helix: ワーキングツリー全体を見る。helix の :sh には端末が付かないので TUI をその場に
  # 出せず、wezterm に隣のペインを開いてもらう ── ここだけ wezterm 依存で、ssh 先の helix
  # では wezterm が無く素直に失敗する（yazi の C-y は端末を借りるので ssh 先でも動く）。
  # ログインシェル越しに起動する理由は modules/wezterm/wezterm.lua の同種のコメント参照。
  programs.helix.settings.keys.normal."C-g" = ":sh wezterm cli split-pane --right --percent 45 -- $SHELL -lc 'hunk diff --theme ${theme}' > /dev/null";
}
