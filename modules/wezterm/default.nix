{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.wezterm.sshHosts = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    example = ["myserver"];
    description = ''
      ランチャーから開けるようにする ssh 先の一覧。`~/.ssh/config` の Host エイリアスを
      そのまま渡す（wezterm ではなくシステムの ssh が解決するため、ProxyCommand や
      証明書認証もそのまま効く）。各要素は `ssh <名前>` という launch_menu の項目になり、
      選ぶと mux サーバ側に ssh のタブが開く（＝GUI を閉じても生き残る）。

      ホスト名は環境ごとの事実なので、このモジュールは一覧を持たず利用側から受け取る。
    '';
  };

  config = {
    # wezterm.lua の font_with_fallback が名前で参照する日本語フォント。
    # これを入れないと CJK のフォールバック先が OS 任せになり、マシンごとに字形が変わる。
    home.packages = [pkgs.noto-fonts-cjk-sans];

    programs.wezterm = {
      enable = true;
      enableZshIntegration = true;
      extraConfig = builtins.readFile ./wezterm.lua;
    };

    # wezterm.lua が設定ファイルと同じディレクトリから dofile する生成物。
    xdg.configFile."wezterm/ssh-hosts.lua".text = ''
      -- このファイルは dotfiles/modules/wezterm/default.nix が
      -- programs.wezterm.sshHosts から生成する。直接編集しない。
      return {
      ${lib.concatMapStrings (host: "  ${builtins.toJSON host},\n") config.programs.wezterm.sshHosts}}
    '';
  };
}
