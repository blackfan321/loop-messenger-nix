{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      packages = rec {
        loop-desktop = pkgs.callPackage ../loop-desktop.nix { };
        default = loop-desktop;
      };
    };
}
