# sources.json のバイナリのパッケージ。sources.json は CI（.github/workflows/dageki.yml）が書き換えるので、
# 手で直さない。CI がまだ一度もビルドしていない（sources.json が空の）間と、ビルドしていない system では null。
#
# passthru.skill は dageki 自身が書き出す skill（`dgk skill install`）。バイナリと同じ版の使い方を
# 配るため、手で写さずにビルドのたびに書き出させる。
{pkgs}: let
  sources = pkgs.lib.importJSON ./sources.json;
  system = pkgs.stdenv.hostPlatform.system;
in
  if sources ? systems.${system}
  then
    pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "dageki";
      inherit (sources) version;
      src = pkgs.fetchurl sources.systems.${system};
      dontUnpack = true;
      installPhase = ''
        install -Dm755 $src $out/bin/dgk
      '';
      passthru.skill = pkgs.runCommand "dageki-skill-${finalAttrs.version}" {} ''
        HOME=$TMPDIR ${finalAttrs.finalPackage}/bin/dgk skill install $out
      '';
      meta = {
        description = "VS Code-style terminal IDE with Helix keybindings";
        mainProgram = "dgk";
        platforms = builtins.attrNames sources.systems;
      };
    })
  else null
