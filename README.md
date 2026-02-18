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

## Usage

Derivation with deno dependencies
```nix
fetchDenoDeps {
    name = "denoDeps";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    src = nix-gitignore.gitignoreSource [ ] ./.;
}
```

Binary from deno project
```nix
buildDenoPackage {
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
buildDenoPackage {
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
