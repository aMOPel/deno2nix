{ nix-gitignore, buildDenoPackage }:
{
  just-jsr-linux = buildDenoPackage rec {
    pname = "test-deno-build-binaries-just-jsr-${targetSystem}";
    version = "0.1.0";
    src = nix-gitignore.gitignoreSource [ ] ./just-jsr;
    binaryEntrypointPath = "./main.ts";
    denoDepsHash = "sha256-yjZ7XCjmjAiCL00XrbwRS6UDTNk72kz9uvv5eborq1I=";
    targetSystem = "x86_64-linux";
  };
  with-https-linux = buildDenoPackage rec {
    pname = "test-deno-build-binaries-with-https-${targetSystem}";
    version = "0.1.0";
    denoDepsHash = "sha256-Ktjoqz1c7FzhXbez2xtqX6hjFnvAFtXu7YxaSRGtTFs=";
    src = nix-gitignore.gitignoreSource [ ] ./with-https;
    denoCompileFlags = [ "--allow-import=unpkg.com:443,jsr.io:443,deno.land:443,esm.sh:443" "--no-check" ];
    binaryEntrypointPath = "./main.ts";
    targetSystem = "x86_64-linux";
  };
  with-https-and-npm-linux = buildDenoPackage rec {
    pname = "test-deno-build-binaries-with-https-and-npm-${targetSystem}";
    version = "0.1.0";
    denoDepsHash = "sha256-VmwJbCXY8du2zkIQCySxwxMBitOuWQO8HQPRXVUiDLg=";
    src = nix-gitignore.gitignoreSource [ ] ./with-https-and-npm;
    denoCompileFlags = [ "--allow-import=unpkg.com:443,jsr.io:443,deno.land:443,esm.sh:443" "--no-check" ];
    binaryEntrypointPath = "./main.ts";
    targetSystem = "x86_64-linux";
  };
  # mac =
  # let
  #   targetSystem = "aarch64-darwin";
  #  macpkgs = import ../../../../default.nix  { crossSystem = { config = "arm64-apple-darwin"; };};
  # in
  # buildDenoPackage {
  #   pname = "test-deno-build-binaries-${targetSystem}";
  #   version = "0.1.0";
  #   denoDepsHash = "";
  #   src = nix-gitignore.gitignoreSource [ ] ./.;
  #   binaryEntrypointPath = "./main.ts";
  #   denortPackage = macpkgs.denort;
  #   inherit targetSystem;
  # };
}
