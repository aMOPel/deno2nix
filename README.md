# deno2nix

This repo contains 2 implementations for a `buildDenoPackage` nix build helper.
Both implementations work.

There were multiple futile attempts to get this merged in nixpkgs.

1. <https://github.com/NixOS/nixpkgs/pull/407434>
2. <https://github.com/NixOS/nixpkgs/pull/419255>
3. <https://github.com/NixOS/nixpkgs/pull/453904>

## Fetch with deno cli

The first attempt is the simpler implementation.

It uses the deno cli to fetch the dependencies and cleans up the non-reproducible files afterwards.

See [**deno-cli-fetcher branch**](https://github.com/aMOPel/deno2nix/tree/deno-cli-fetcher)

This was merged and later reverted, since this is not good practice in nixpkgs,
for complicated technical reasons, that only matter for nixpkgs.

## Custom made fetcher

The second and third attempts use a custom-made fetcher that is
supposed to have the same functionality as the deno cli fetcher.

See [**custom-made-fetcher branch**](https://github.com/aMOPel/deno2nix/tree/custom-made-fetcher)

This was never merged, since nobody could be bothered to review that amount of code.
