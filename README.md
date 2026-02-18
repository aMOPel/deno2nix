# deno2nix

This repo contains 2 implementations for a `buildDenoPackage` nix build helper.

**Both implementations work.**

There were multiple futile attempts to get this merged in nixpkgs.

1. <https://github.com/NixOS/nixpkgs/pull/407434>
2. <https://github.com/NixOS/nixpkgs/pull/419255>
3. <https://github.com/NixOS/nixpkgs/pull/453904>

## Fetch with deno cli

The first attempt is the simpler implementation.

It uses the deno cli to fetch the dependencies and cleans up the non-reproducible files afterwards.

Since it uses the deno cli, it naturally has all the fetcher features of the deno cli.

**WARNING:** For newer deno versions, the `fetchDenoDeps` derivations can become non-reproducible,
if deno upstream adds more non-reproducible data to the dependency directories (`DENO_DIR`, vendir-dir, node_modules)

- `deno.lock`
- their internal formats for `DENO_DIR` and vendor-dir

See [**deno-cli-fetcher branch**](https://github.com/aMOPel/deno2nix/tree/deno-cli-fetcher)

This was merged and later reverted, since this is not good practice in nixpkgs,
for complicated technical reasons, that only matter for the nixpkgs repo.

## Custom made fetcher

As per request by the nixpkgs maintainers,
the second and third attempts use a custom-made fetcher that
aims to mimic the functionality of the deno cli fetcher.

The implementation is more complicated and has fewer features.

**WARNING:** For newer deno versions, the fetcher can break (i.e. not produce usable output anymore),
if deno upstream makes breaking changes to:
- `deno.lock`
- their internal formats for `DENO_DIR` and vendor-dir

See [**custom-made-fetcher branch**](https://github.com/aMOPel/deno2nix/tree/custom-made-fetcher)

This was never merged, since nobody could be bothered to review that amount of code.
