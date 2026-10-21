# hunk (差分ビューア)。差分を読む場所を1つに寄せるモジュールで、git のページャと
# helix / yazi からの入口をまとめて持つ。
{ pkgs, ... }:
let
  # 端末 (ghostty / kitty の GitHub Dark) と helix の github_dark に色を揃える。
  theme = "github-dark";
in
{
  home.packages = [ pkgs.hunk ];

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
  # 出せず、herdr に隣のペインを開いてもらう。端末の分割ではなく herdr なのは、herdr の入った
  # ssh 先の helix でも同じキーで動くため（yazi の C-y は端末を借りるので herdr も要らない）。
  # 新しいペインのシェルに hunk を流し、終えたら exit でペインごと閉じる。
  programs.helix.settings.keys.normal."C-g" =
    '':sh pane=$(herdr pane split --current --direction right --ratio 0.45 --cwd "$PWD" --focus | sed -n 's/.*"pane_id":"\([^"]*\)".*/\1/p') && herdr pane run "$pane" 'hunk diff --theme ${theme}; exit' > /dev/null'';
}
