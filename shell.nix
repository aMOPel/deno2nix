let
  sources = import ./lon.nix;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    deno
    gnumake
    lon
  ];
  DENO_DIR = "./.deno";

  shellHook = '''';
}
