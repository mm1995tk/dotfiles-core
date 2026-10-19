# dageki（VS Code の画面と Helix の操作の TUI エディタ。コマンドは dgk）。ソースは private なので、platform の CI
# （.github/workflows/dageki.yml）がビルドしたバイナリを dotfiles-core の Releases から取る（package.nix）。
{
  lib,
  pkgs,
  ...
}: let
  dageki = import ./package.nix {inherit pkgs;};
  toml = pkgs.formats.toml {};
in {
  home.packages = lib.optional (dageki != null) dageki;

  # 形式は Helix の languages.toml と同じで、組み込みの既定値に name ごとに重ねる（既定の nix は nil）。
  xdg.configFile."dageki/languages.toml" = lib.mkIf (dageki != null) {
    source = toml.generate "dageki-languages.toml" {
      language-server.nixd.command = lib.getExe pkgs.nixd;
      language = [
        {
          name = "nix";
          language-servers = ["nixd"];
        }
      ];
    };
  };
}
