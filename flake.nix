{
  description = "It's a me, wahoo man mario";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = {
    self,
    nixpkgs,
  } @ inputs: let
    systems = [
      "x86_64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;

    pkgsFor = system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [self.overlays.default];
      };
      overlay = self.overlays.default pkgs pkgs;
    in
      overlay // {default = pkgs.callPackage ./package.nix {};};
  in let
    packages' = forAllSystems pkgsFor;
  in {
    inherit (import ./flake.nix) nixConfig;
    packages = packages';

    overlays.default = import ./overlay.nix;

    formatter = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
        pkgs.alejandra
    );
  };

  nixConfig = {
    extra-substituters = [
      "https://wahoo-wahoo-man.cachix.org/"
    ];
    extra-trusted-public-keys = [
      "wahoo-wahoo-man.cachix.org-1:4pFCpQO1n3M4DCyiPaGA4sPhPvMoCVh8szCTdiNcvzI="
    ];
  };
}
