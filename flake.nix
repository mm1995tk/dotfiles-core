{
  description = "Nix System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    flake-utils,
    home-manager,
    nixpkgs,
    nixpkgs-stable,
    treefmt-nix,
    ...
  } @ inputs: let
    mk-pkgs = input: system:
      import input {
        inherit system;
        config.allowUnfree = true;
      };
    homeStateVersion = {
      home.stateVersion = "25.11";
    };
  in
    {
      mkDotfilesConf = let
        # impure オプションを前提
        mkHomeManager = modules:
          home-manager.lib.homeManagerConfiguration {
            pkgs = mk-pkgs nixpkgs builtins.currentSystem;
            extraSpecialArgs = {
              inherit inputs;
              pkgs-stable = mk-pkgs nixpkgs-stable builtins.currentSystem;
            };
            inherit modules;
          };
      in
        {
          universal-path,
          cli-path,
          gui-path,
        }: {
          cli = mkHomeManager [homeStateVersion ./src/universal.nix universal-path ./src/cli.nix cli-path];
          gui = mkHomeManager [homeStateVersion ./src/universal.nix universal-path ./src/gui.nix gui-path];
        };
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = mk-pkgs nixpkgs system;
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./flake_treefmt.nix;
    in {
      formatter = treefmtEval.config.build.wrapper;
      checks.formatting = treefmtEval.config.build.check self;
    });
}
