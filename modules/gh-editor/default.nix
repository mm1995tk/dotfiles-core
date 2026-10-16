# gh-editor（VS Code の画面と Helix の操作の TUI エディタ）。ソースは private なので、platform の CI
# （.github/workflows/gh-editor.yml）がビルドしたバイナリを dotfiles-core の Releases から取る（package.nix）。
{
  lib,
  pkgs,
  ...
}: let
  gh-editor = import ./package.nix {inherit pkgs;};
in {
  home.packages = lib.optional (gh-editor != null) gh-editor;
}
