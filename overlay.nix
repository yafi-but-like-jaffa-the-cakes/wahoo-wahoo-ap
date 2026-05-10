let
  names = builtins.map (
    value: builtins.substring 0 ((builtins.stringLength value) - 4) value
  ) (builtins.attrNames (builtins.readDir ./packages));
in
  final: prev:
    builtins.listToAttrs (builtins.map (n: {
        name = n;
        value = final.callPackage ./packages/${n}.nix {};
      })
      names)
