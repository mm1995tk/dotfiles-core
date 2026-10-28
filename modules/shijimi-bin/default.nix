# programs.shijimi-editor.package を、shijimi-editor の GitHub Release に置かれたビルド済みの shj にする。
# 既定のパッケージはソースからビルドし、その途中で Go のモジュールを取りに行くので、それを通さないプロキシの
# 内側ではビルドできない。これを import すれば github.com からのダウンロードだけで入る。shijimi と同じく、
# オプションを宣言する shijimi-editor の flake のモジュールも import する。
#
# sources.json は CI（.github/workflows/update-shijimi.yml）が書き換えるので、手で直さない。sources.json に
# 無い system では何もしない（ソースからのビルドのまま）。
{
  lib,
  pkgs,
  ...
}:
let
  sources = lib.importJSON ./sources.json;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  programs.shijimi-editor.package = lib.mkIf (sources.systems ? ${system}) (
    lib.mkDefault (
      pkgs.stdenvNoCC.mkDerivation {
        pname = "shijimi";
        inherit (sources) version;
        src = pkgs.fetchurl sources.systems.${system};
        dontUnpack = true;
        installPhase = ''
          install -Dm755 $src $out/bin/shj
          ln -s shj $out/bin/shijimi
        '';
        meta = {
          description = "VS Code-style terminal IDE with Helix keybindings";
          license = lib.licenses.mit;
          mainProgram = "shj";
          platforms = builtins.attrNames sources.systems;
        };
      }
    )
  );
}
