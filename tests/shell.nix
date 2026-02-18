let
  sources = import ../lon.nix;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  buildInputs = [ pkgs.deno ];
  DENO_DIR = "./.deno";

  shellHook = '''';
}
