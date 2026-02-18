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
  denoHooks = pkgs.callPackage ./build-deno-package/hooks/default.nix { };

  fetch-deno-deps-scripts = {
    deno = (pkgs.callPackage ./fetch-deno-deps/scripts/deno/default.nix { }).fetch-deno-deps-scripts;
    rust =
      (pkgs.callPackage ./fetch-deno-deps/scripts/rust/file-structure-transformer-vendor/default.nix { })
      .file-structure-transformer-vendor;
  };

  denort = pkgs.callPackage ./denort/default.nix { };

  pkgs' = import sources.nixpkgs {
    overlays = [
      (self: super: {
        inherit
          buildDenoPackage
          fetch-deno-deps-scripts
          fetchDenoDeps
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
