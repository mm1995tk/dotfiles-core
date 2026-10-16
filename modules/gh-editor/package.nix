# sources.json のバイナリのパッケージ。sources.json は CI（.github/workflows/gh-editor.yml）が書き換えるので、
# 手で直さない。CI がまだ一度もビルドしていない（sources.json が空の）間と、ビルドしていない system では null。
#
# passthru.skill は gh-editor 自身が書き出す skill（`gh-editor skill install`）。バイナリと同じ版の使い方を
# 配るため、手で写さずにビルドのたびに書き出させる。
{pkgs}: let
  sources = pkgs.lib.importJSON ./sources.json;
  system = pkgs.stdenv.hostPlatform.system;
in
  if sources ? systems.${system}
  then
    pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "gh-editor";
      inherit (sources) version;
      src = pkgs.fetchurl sources.systems.${system};
      dontUnpack = true;
      installPhase = ''
        install -Dm755 $src $out/bin/gh-editor
      '';
      passthru.skill = pkgs.runCommand "gh-editor-skill-${finalAttrs.version}" {} ''
        HOME=$TMPDIR ${finalAttrs.finalPackage}/bin/gh-editor skill install $out
      '';
      meta = {
        description = "VS Code-style terminal IDE with Helix keybindings";
        mainProgram = "gh-editor";
        platforms = builtins.attrNames sources.systems;
      };
    })
  else null
