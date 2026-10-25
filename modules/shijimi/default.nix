# shijimi（VS Code の画面と Helix の操作の TUI エディタ。コマンドは shj）の設定。
# オプション programs.shijimi-editor は shijimi-editor の flake の home-manager モジュールが宣言するので、
# 使う側はそれも import する（platform では dotfiles/default.nix が重ねる）。
{
  lib,
  pkgs,
  ...
}:
{
  programs.shijimi-editor = {
    enable = lib.mkDefault true;
    # 形式は Helix の languages.toml と同じで、組み込みの既定値に name ごとに重ねる（既定の nix は nil）。
    languages = {
      language-server.nixd.command = lib.getExe pkgs.nixd;
      language = [
        {
          name = "nix";
          language-servers = [ "nixd" ];
        }
      ];
    };
  };
}
