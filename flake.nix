{
  description = "It's a me, wahoo man mario";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

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
      overlay;
  in {
    inherit (import ./flake.nix) nixConfig;
    packages = forAllSystems pkgsFor;

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
}
