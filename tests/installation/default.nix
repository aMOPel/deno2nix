let
  # deno 2.6.4
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/4c579d27f4e9ae093e3e0326a0b7bf80e106df1c.tar.gz";
  }) { };
  deno2nixSrc = pkgs.nix-gitignore.gitignoreSource [ ] ../../.;
  # deno2nixSrc = pkgs.fetchFromGithub {
  #   repo = "deno2nix";
  #   owner = "aMOPel";
  #   rev = "117817488569489bfe3a4e3ae0b7350206afaed1";
  #   sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
  # };

  # (optional) inject your own nixpkgs if necessary
  deno2nix = import deno2nixSrc { inherit pkgs; };
in
deno2nix.lib.buildDenoPackage {
  pname = "test-deno-build";
  version = "0.1.0";
  denoDepsHash = "sha256-RqzZHvDflga7fAz2GrSy27FiZkfgqZE6jpsvoS986I8=";
  src = pkgs.nix-gitignore.gitignoreSource [ ] ./.;
  # (optional) override the deno version
  denoPackage = pkgs.deno;
  denoTaskSuffix = ">out.txt";
  extraTaskFlags = [
    "--text"
    "installation-test"
  ];
  installPhase = ''
    deno --version >>out.txt
    cp out.txt $out
  '';
}
