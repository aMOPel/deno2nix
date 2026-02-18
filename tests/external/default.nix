{ fetchFromGitHub, buildDenoPackage }:
{
  readma-cli-linux = buildDenoPackage rec {
    pname = "readma-cli";
    version = "2.11.0";
    denoDepsHash = "sha256-+l7qn/VCsbQHNBgNv3kRxonYHpeszkE6bbjO3GCfp/0=";
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
    denoDepsHash = "sha256-pi+yCb6yq043XDhndOSPb2MtY2ooY9z+Sp+qnszK4+A=";
    src = fetchFromGitHub {
      owner = "denoland";
      repo = "fresh";
      rev = "c7c341b695bad8d0f3e3575e5fa9c82e0fa28bd4";
      hash = "sha256-bC4akr4Wt4sRqGkgjNuXztW8Q6YBLBsbuIOhsXH8NQU=";
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
      rev = "6c76cab5b22ee2d533fd115135d0bd397aa4d938";
      hash = "sha256-qWLDqrJk0PySFcx2ke8DRzxK+LQfT4dKRFVgEd3EYsI=";
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
