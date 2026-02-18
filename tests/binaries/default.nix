{ nix-gitignore, buildDenoPackage }:
{
  with-npm-linux = buildDenoPackage rec {
    pname = "test-deno-build-binaries-with-npm-${targetSystem}";
    version = "0.1.0";
    denoDepsHash = "sha256-RqzZHvDflga7fAz2GrSy27FiZkfgqZE6jpsvoS986I8=";
    src = nix-gitignore.gitignoreSource [ ] ./with-npm;
    binaryEntrypointPath = "./main.ts";
    targetSystem = "x86_64-linux";
  };
  without-npm-linux = buildDenoPackage rec {
    pname = "test-deno-build-binaries-without-npm-${targetSystem}";
    version = "0.1.0";
    denoDepsHash = "sha256-K/JtpZGPkskkbq0DaBmXeot6tBacbL+SL9i2xBJYzVM=";
    src = nix-gitignore.gitignoreSource [ ] ./without-npm;
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
