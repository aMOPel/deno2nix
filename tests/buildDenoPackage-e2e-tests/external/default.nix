{ fetchFromGitHub, buildDenoPackage }:
{
  readma-cli-linux = buildDenoPackage rec {
    pname = "readma-cli";
    version = "2.11.0";
    denoDepsHash = "sha256-q5HIA7Tgf6ru4FAC4U1maghVgLyqsqrH8o5d33hJSXM=";
    src = fetchFromGitHub {
      owner = "elcoosp";
      repo = "readma";
      rev = "${version}";
      hash = "sha256-FVQTn+r7Ztj02vNvqFZIRIsokWeo1tPfFYffK2tvxjA=";
    };
    denoInstallFlags = [
      "--allow-scripts"
      "--frozen"
      "--cached-only"
      "--entrypoint"
      "./cli/mod.ts"
    ];
    binaryEntrypointPath = "./cli/mod.ts";
    targetSystem = "x86_64-linux";
  };
  fresh-init-cli-linux = buildDenoPackage {
    pname = "fresh-init-cli";
    version = "";
    denoDepsHash = "sha256-rdOIvl+6lWc1HCPoZ8zj3V3U0qol/HqMsWjzH2U1G50=";
    src = fetchFromGitHub {
      owner = "denoland";
      repo = "fresh";
      rev = "4cc76aefed73ec15e77d5314ae57f0014387e50b";
      hash = "sha256-6hieqTWFnKsEtkyiVAeDXhpFFSnTOuJ7qh0ZX/AW46o=";
    };
    denoWorkspacePath = "./init";
    binaryEntrypointPath = "./src/mod.ts";
    targetSystem = "x86_64-linux";
  };
  invidious-companion-cli-linux = buildDenoPackage {
    pname = "invidious-companion-cli";
    version = "";
    denoDepsHash = "";
    src = fetchFromGitHub {
      owner = "iv-org";
      repo = "invidious-companion";
      rev = "a34c27ff63e51f9e3adc0e8647cd12382f8f1ffe";
      hash = "sha256-/S8F7G8li12k0objsdFuh+mle6p2mk8zNUUCrG9hgns=";
    };
    binaryEntrypointPath = "src/main.ts";
    denoCompileFlags = [
      "--include=./src/lib/helpers/youtubePlayerReq.ts"
      "--include=./src/lib/helpers/getFetchClient.ts"
      "--allow-import=github.com:443,jsr.io:443,cdn.jsdelivr.net:443,esm.sh:443,deno.land:443"
      "--allow-net"
      "--allow-env"
      "--allow-read"
      "--allow-sys=hostname"
      "--allow-write=/var/tmp/youtubei.js"
      "--no-check"
    ];
    denoInstallFlags = [
      "--allow-scripts"
      "--frozen"
      "--cached-only"
      "--entrypoint"
      "src/main.ts"
    ];
    targetSystem = "x86_64-linux";
  };
}
