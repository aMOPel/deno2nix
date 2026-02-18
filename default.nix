let
  sources = import ./lon.nix;
  nixpkgs = import sources.nixpkgs { };
in
{
  pkgs ? nixpkgs,
}:
let
  fetchDenoDeps = pkgs.callPackage ./fetch-deno-deps/default.nix { };
  buildDenoPackage = pkgs.callPackage ./build-deno-package/default.nix {
    inherit denoHooks fetchDenoDeps;
  };
  denoHooks = pkgs.callPackage ./build-deno-package/hooks/default.nix { denort = null; };

  denort = pkgs.callPackage ./denort/default.nix { };

  pkgs' = import sources.nixpkgs {
    overlays = [
      (self: super: {
        inherit
          buildDenoPackage
          ;
      })
    ];
  };

  tests = pkgs'.callPackage ./tests/default.nix { };
in
{
  lib = {
    inherit
      fetchDenoDeps
      buildDenoPackage
      denoHooks
      ;
  };
  packages = {
    inherit denort;
  };
  checks = {
    inherit tests;
  };
}
