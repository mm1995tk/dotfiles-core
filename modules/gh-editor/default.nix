# gh-editor（VS Code の画面と Helix の操作の TUI エディタ）。ソースは private なので、platform の CI
# （.github/workflows/gh-editor.yml）がビルドしたバイナリを dotfiles-core の Releases から取る（package.nix）。
{
  lib,
  pkgs,
  ...
}: let
  gh-editor = import ./package.nix {inherit pkgs;};
in {
  # gh の拡張として `gh editor` でも呼べるようにする（gh は PATH ではなく自分の拡張のディレクトリしか探さない）。
  # PATH にも置くのは、gh-editor の skill が `gh-editor` で呼ぶため。
  home.packages = lib.optional (gh-editor != null) gh-editor;
  programs.gh.extensions = lib.optional (gh-editor != null) gh-editor;
}
