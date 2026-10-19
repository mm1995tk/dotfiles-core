# sources.json のバイナリのパッケージ。sources.json は CI（.github/workflows/shijimi.yml）が書き換えるので、
# 手で直さない。CI がまだ一度もビルドしていない（sources.json が空の）間と、ビルドしていない system では null。
#
# passthru.skill は shijimi 自身が書き出す skill（`shj skill install`）。バイナリと同じ版の使い方を
# 配るため、手で写さずにビルドのたびに書き出させる。
{pkgs}: let
  sources = pkgs.lib.importJSON ./sources.json;
  system = pkgs.stdenv.hostPlatform.system;
in
  if sources ? systems.${system}
  then
    pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "shijimi";
      inherit (sources) version;
      src = pkgs.fetchurl sources.systems.${system};
      dontUnpack = true;
      installPhase = ''
        install -Dm755 $src $out/bin/shj
      '';
      passthru.skill = pkgs.runCommand "shijimi-skill-${finalAttrs.version}" {} ''
        HOME=$TMPDIR ${finalAttrs.finalPackage}/bin/shj skill install $out
      '';
      meta = {
        description = "VS Code-style terminal IDE with Helix keybindings";
        mainProgram = "shj";
        platforms = builtins.attrNames sources.systems;
      };
    })
  else null
