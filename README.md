# deno2nix

This project provides nix build-helpers to create derivations from deno projects.

## Features

- `fetchDenoDeps`: create derivation of deno dependencies from `deno.lock` file
- `buildDenoPackage`:
    - either create binary from deno project
    - or run deno project inside nix-build and copy artifacts to `$out`
- supports private npm registries
- supports workspaces
- supports all native deno dependency fetching features, since it just uses the deno cli under the hood

## Installation

```nix
let
  # deno 2.6.4
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/4c579d27f4e9ae093e3e0326a0b7bf80e106df1c.tar.gz";
  }) { };
  deno2nixSrc = pkgs.fetchFromGithub {
    repo = "deno2nix";
    owner = "aMOPel";
    # TODO: update rev
    rev = "117817488569489bfe3a4e3ae0b7350206afaed1";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
  };

  # inject your own nixpkgs
  deno2nix = import deno2nixSrc { inherit pkgs; };
in
{
  # ...
}
```

## Usage

Derivation with deno dependencies
```nix
deno2nix.lib.fetchDenoDeps {
    name = "denoDeps";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    src = nix-gitignore.gitignoreSource [ ] ./.;
}
```

Binary from deno project
```nix
deno2nix.lib.buildDenoPackage {
  pname = "myPackage";
  version = "0.1.0";
  denoDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
  src = nix-gitignore.gitignoreSource [ ] ./.;
  binaryEntrypointPath = "main.ts";
}
```

Artifact from executing deno project
```json title="deno.json"
{
    "tasks": {
        "build": "deno run --allow-all main.ts"
    }
}
```

```nix
{ buildDenoPackage, nix-gitignore }:
deno2nix.lib.buildDenoPackage {
  pname = "myPackage";
  version = "0.1.0";
  denoDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
  src = nix-gitignore.gitignoreSource [ ] ./.;
  denoTaskSuffix = ">out.txt";
  installPhase = ''
    cp ./out.txt $out
  '';
}
```

For more Details see the [**User Docs**](./docs/user/readme.md)
