# shijimi（VS Code の画面と Helix の操作の TUI エディタ。コマンドは shj）。ソースは private なので、platform の CI
# （.github/workflows/shijimi.yml）がビルドしたバイナリを dotfiles-core の Releases から取る（package.nix）。
{
  lib,
  pkgs,
  ...
}:
let
  shijimi = import ./package.nix { inherit pkgs; };
  toml = pkgs.formats.toml { };
in
{
  home.packages = lib.optional (shijimi != null) shijimi;

  # 形式は Helix の languages.toml と同じで、組み込みの既定値に name ごとに重ねる（既定の nix は nil）。
  xdg.configFile."shijimi/languages.toml" = lib.mkIf (shijimi != null) {
    source = toml.generate "shijimi-languages.toml" {
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
