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
  }:
    import ./modules.nix
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
