{
  deno,
  lib,
}:
deno.overrideAttrs (
  final: prev: {
    pname = "denort";
    postInstall =
      builtins.replaceStrings
        [
          ''find $out/bin/* -not -name "deno" -delete''
        ]
        [
          ''find $out/bin/* -not -name "deno" -not -name "denort" -delete''
        ]
        prev.postInstall;
    meta = with lib; {
      homepage = "https://deno.land/";
      changelog = "https://github.com/denoland/deno/releases/tag/v${final.version}";
      description = "Slim version of the deno runtime, usually bundled with deno projects into standalone binaries";
      license = licenses.mit;
      mainProgram = "denort";
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    };
  }
)
