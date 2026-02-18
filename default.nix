let
  sources = import ./lon.nix;
  pkgs = import sources.nixpkgs { };

  fetchDenoDeps = pkgs.callPackage ./fetch-deno-deps/default.nix { };
  buildDenoPackage = pkgs.callPackage ./build-deno-package/default.nix {
    inherit denoHooks fetchDenoDeps denort;
  };
  denoHooks = pkgs.callPackage ./build-deno-package/hooks/default.nix { inherit denort; };

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
