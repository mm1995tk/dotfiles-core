# modules/ 直下のエントリ (xxx.nix または default.nix を持つディレクトリ) を
# 自動発見し、{ <名前> = <モジュールへのパス>; } の attrset を返す。
# flake.nix の outputs として公開されるほか、homelab からは直接 import される。
let
  modulesDir = ./modules;
  moduleEntries = builtins.readDir modulesDir;
in
  builtins.listToAttrs (
    builtins.concatMap (
      name:
        if moduleEntries.${name} == "directory" || (moduleEntries.${name} == "regular" && builtins.match ".*\\.nix" name != null)
        then [
          {
            name = builtins.replaceStrings [".nix"] [""] name;
            value = modulesDir + "/${name}";
          }
        ]
        else []
    ) (builtins.attrNames moduleEntries)
  )
