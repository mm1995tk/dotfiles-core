# yazi (TUI ファイルマネージャ)。helix と組ませる前提で置いている ── helix には
# ファイルツリーが無く、開いていないファイルを「眺めながら選ぶ」手段が弱いので、
# その穴を埋める役。単体で使うときは zsh 関数 `y` で開き、抜けた先へシェルごと cd する。
{pkgs, ...}: let
  # yazi が選択結果を書き出す先。helix 側は同じファイルを読んで :open する。
  # 公式レシピは /tmp の固定パスだが、他人と共用のマシンで衝突しない位置へ移してある。
  chooserDir = "$HOME/.cache/helix";
  chooserFile = "${chooserDir}/yazi-chooser";
in {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    # piper は任意のコマンドの出力をプレビューにする公式プラグイン。markdown を glow に通すのに使う。
    # 専用の glow.yazi ではなくこちらなのは、前者が piper の登場で deprecated になっており、
    # プレビュー幅も 55 桁固定でペイン幅に追従しないため。
    plugins = {
      inherit (pkgs.yaziPlugins) piper zoom git vcs-files smart-enter toggle-pane;
    };

    # glow は piper が、magick は zoom が PATH から探す。home.packages ではなく yazi のラッパーに
    # 同梱するのは、プレビューでしか使わないコマンドをシェルの PATH に出さないため。
    extraPackages = [pkgs.glow pkgs.imagemagick];

    # git はファイル一覧の各行に変更の状態を出す。この setup と下の fetchers の登録が揃って初めて動く。
    initLua = ''
      require("git"):setup()
    '';

    # キーは yazi の既定と衝突しないものを選ぶ。例外は意図して上書きする 2 つ:
    #   - l: smart-enter で、ファイルの上でも開けるようにする（ディレクトリでは既定の enter と同じ）
    #   - -: 既定は絶対パスのシンボリックリンク。zoom の + と対にするため譲る（相対パスの _ は残る）
    # vcs-files の README の例 g c は、既定の「~/.config へ移動」と衝突するので g v にしている。
    keymap.mgr.prepend_keymap = [
      {
        on = "l";
        run = "plugin smart-enter";
        desc = "Enter the child directory, or open the file";
      }
      {
        on = "+";
        run = "plugin zoom 1";
        desc = "Zoom in hovered file";
      }
      {
        on = "-";
        run = "plugin zoom -1";
        desc = "Zoom out hovered file";
      }
      {
        on = ["g" "v"];
        run = "plugin vcs-files";
        desc = "Show Git file changes";
      }
      {
        on = "T";
        run = "plugin toggle-pane max-preview";
        desc = "Maximize or restore the preview pane";
      }
    ];

    settings = {
      # opener は既定のまま $EDITOR（modules/helix.nix）に任せ、ここには hx と書かない。
      mgr.show_hidden = true; # helix の file-picker.hidden = false と揃える

      # 既定では text/* として色付きのソースが出るだけなので、markdown だけ整形して見せる。
      # -s=dark 固定なのは端末・helix・hunk と揃えるため（$t で端末に追従させることもできる）。
      plugin.prepend_previewers = [
        {
          url = "*.md";
          run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
        }
      ];

      plugin.prepend_fetchers = [
        {
          url = "*";
          run = "git";
          group = "git";
        }
        {
          url = "*/";
          run = "git";
          group = "git";
        }
      ];
    };
  };

  # helix からの入口。yazi 公式の Helix 連携レシピ
  # (https://yazi-rs.github.io/docs/tips) をなぞっている。
  #
  # 肝は :insert-output が helix の端末をそのまま子プロセスへ貸すこと。wezterm のペイン
  # 分割に頼らないので、ssh 先の helix でも同じキーで動く。
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
