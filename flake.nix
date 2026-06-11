{
  description = "Nix System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    treefmt-nix,
    ...
  }: let
    modulesDir = ./modules;
    moduleEntries = builtins.readDir modulesDir;
    moduleAttrs = builtins.listToAttrs (
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
    );
  in
    moduleAttrs
    // flake-utils.lib.eachDefaultSystem (system: let
      treefmtEval =
        treefmt-nix.lib.evalModule (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        })
        ./flake_treefmt.nix;
    in {
      formatter = treefmtEval.config.build.wrapper;
      checks.formatting = treefmtEval.config.build.check self;
    });
}
