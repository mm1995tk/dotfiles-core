# Ghostty の窓と文字の設定。分割・タブ・作業の永続化は多重化ツール（standard では herdr。
# 起動のしかたは features/herdr-desktop.nix）が担当するので、Ghostty 自身は 1 枚の窓だけを持つ。
#
# リンクは既定のまま: macOS では cmd を押しながら URL に乗せると下線が出て、cmd+クリックで開く。
#
# Enter は改行、cmd+Enter が実行・送信。端末が持つのは cmd+Enter に Ctrl-J と同じ文字を送らせる所まで
# で、Enter を改行にするのは受け側（zsh は modules/zsh、Claude Code は features/coding-agents.nix）。
{
  config,
  lib,
  pkgs,
  ...
}: {
  # font-family が名前で参照するフォント。どちらも入れないとフォールバック先が OS 任せになり、
  # マシンごとに字形が変わる。
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts-cjk-sans
  ];

  programs.ghostty = {
    enable = true;
    # nixpkgs の ghostty は Linux 向けのソースビルドで、macOS は公式のバイナリを包んだ ghostty-bin が別にある。
    package =
      if pkgs.stdenv.hostPlatform.isDarwin
      then pkgs.ghostty-bin
      else pkgs.ghostty;

    settings = {
      # 16 色パレットと背景・前景の実体はここで決める。starship 側は "blue" のような色名で
      # 参照するだけにして、色の定義がふたつに散らないようにしている。
      theme = "GitHub Dark";

      # JetBrains Mono の Nerd Font パッチ版には CJK の字形が無く、次点を書かないと漢字の描画が
      # OS のフォールバック順任せになる。中国語フォントが先に拾われるマシンでは「実」のような
      # 日本語字形が化けるため、次点を明示して固定する。
      #
      # Nerd Font には Mono / Propo / 無印の 3 系統があり、記号を 1 セルに収めるのは Mono だけ。
      # 無印は記号が 2 セル幅で、yazi のような桁を揃える TUI で列がずれる。
      font-family = [
        "JetBrainsMono Nerd Font Mono"
        "Noto Sans Mono CJK JP"
      ];
      font-feature = "-calt, -liga, -dlig";

      window-width = 178;
      window-height = 48;
      window-padding-x = 8;
      window-padding-y = 8;
      macos-option-as-alt = true;

      keybind = [
        # Ghostty の中にタブや分割を作ると多重化ツールのものと二重になり、どちらのキーで動かすかを
        # 取り違えるので、既定のキーを潰しておく。
        "super+t=unbind"
        "super+d=unbind"
        "super+shift+d=unbind"
        "shift+enter=text:\\n"
        # 既定は全画面の切り替え。
        "super+enter=text:\\n"
      ];
    };
  };

  # Finder から起動すると作業ディレクトリがホームになる。~/workspace を置く決まりのある macOS だけに絞る。
  programs.ghostty.settings.working-directory = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "${config.home.homeDirectory}/workspace";
}
