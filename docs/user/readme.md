### buildDenoPackage

`buildDenoPackage` allows you to package [Deno](https://deno.com/) projects in Nixpkgs without the use of an auto-generated dependencies file (as used in [node2nix](#javascript-node2nix)).
It works by utilizing Deno's cache functionality -- creating a reproducible cache that contains the dependencies of a project, and pointing Deno to it.

**IMPORTANT**:

There are a number of features that are supported by the Deno CLI, but not by this build helper.
If a package uses one of those features, this build helper can't be used.

- [`nodeModulesDir`](https://docs.deno.com/runtime/fundamentals/node/#node_modules) &
[`--allow-scripts`](https://docs.deno.com/runtime/reference/CLI/add/#options-allow-scripts)
- [private HTTPS repositories](https://docs.deno.com/runtime/fundamentals/modules/#private-repositories)
- [`.npmrc`](https://docs.npmjs.com/CLI/v8/configuring-npm/npmrc)

#### fetchDenoDeps

For every `buildDenoPackage`, first, a [fixed output derivation](https://nix.dev/manual/nix/2.18/language/advanced-attributes.html#adv-attr-outputHash) is
created with all the dependencies mentioned in the `deno.lock`.
This works as follows:
1. The `deno.lock` is parsed and transformed. (available as a passthru at `<packageBuild>.denoDeps.transformedDenoLock`)
1. The dependencies are fetched using JavaScript. (available as a passthru at `<packageBuild>.denoDeps.fetched`)
1. Inside the `buildDenoPackage` derivation
  1. The fetched files are translated into a format that Deno understands. (available as a passthru at `<packageBuild>.denoDeps.denoDeps`)
  1. The dependencies are installed again using `deno install`, from the local cache only.

Deno differentiates between 3 kinds of dependencies:

- `npm:` from <https://npmjs.com>
- `jsr:` from <https://jsr.io>
- `https:` from JavaScript CDNs like:
  - `deno.land/x`
  - `esm.sh`
  - `unpkg.com`

(This is more or less how every build helper works)

The `fetchDenoDeps` derivation is in `passthru`, so it can be accessed from a `buildDenoPackage` derivation with `.denoDeps`.

Related options:

- *`denoDepsHash`* (String): The output hash of the `fetchDenoDeps` fixed output derivation.
- *`denoInstallFlags`* (Array of strings; optional): The Flags passed to `deno install`.
    - _Default:_ `[ "--allow-scripts" "--frozen" "--cached-only" ]`

<details>

<summary>
Tip
</summary>

If you receive errors like these:

```
error: The lockfile is out of date. Run `deno install --frozen=false`, or rerun with `--frozen=false` to update it.
```

or

```
error: Import '<url>' failed.
    0: error sending request for url (<url>): client error (Connect): dns error: failed to lookup address information: Temporary failure in name resolution: failed to lookup address information:Temporary failure in name resolution
    1: client error (Connect)
    2: dns error: failed to lookup address information: Temporary failure in name resolution
    3: failed to lookup address information: Temporary failure in name resolution
    at file:///build/source/src/lib/helpers/verifyRequest.ts:2:21
build for <your-package> failed in buildPhase with exit code 1
```

or

```
error: Specifier not found in cache: "<url>", --cached-only is specified.

ERROR: deno failed to install dependencies
```

This can happen due to the `deno install` command deducing different packages than what the actual package needs.

To fix this, add the entrypoint to the install flags:

```nix
{ buildDenoPackage, nix-gitignore }:
buildDenoPackage {
  pname = "myPackage";
  version = "0.1.0";
  denoDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
  src = nix-gitignore.gitignoreSource [ ] ./.;
  binaryEntrypointPath = "main.ts";
  denoInstallFlags = [
    "--allow-scripts"
    "--frozen"
    "--cached-only"
    "--entrypoint"
    "<path/to/entrypoint/script>"
  ];
}
```

</details>

#### Compile to binary

It's possible to compile a Deno project to a single binary using `deno compile`.
The binary will be named like the `.name` property in `deno.json`, if available,
or the `name` attribute of the derivation.

**WARNING**:
When using packages with a `npm:` specifier, the resulting binary will not be reproducible.
See [this issue](https://github.com/denoland/deno/issues/29619) for more information.

**WARNING**:
The `denort` package does not exist in `nixpkgs` and is not in the nix cache,
and building it takes a very long time.

Related options:

- *`hostPlatform`* (String; optional): The [host platform](#ssec-cross-platform-parameters) the binary is built for.
    - _Default:_ `builtins.currentSystem`.
    - _Supported values:_
      - `"x86_64-darwin"`
      - `"aarch64-darwin"`
      - `"x86_64-linux"`
      - `"aarch64-linux"`

- *`denoCompileFlags`* (Array of string; optional): Flags passed to `deno compile [denoTaskFlags] ${binaryEntrypointPath} [extraCompileFlags]`.
- *`extraCompileFlags`* (Array of string; optional): Flags passed to `deno compile [denoTaskFlags] ${binaryEntrypointPath} [extraCompileFlags]`.
- *`binaryEntrypointPath`* (String or null; optional): If not `null`, a binary is created using the specified path as the entry point.
  The binary is copied to `$out/bin` in the `installPhase`.
    - _Default:_ `null`
    - It's prefixed by `denoWorkspacePath`.
- *`denortPackage`* (Derivation; optional): The package used as the Deno runtime, which is bundled with the JavaScript code to create the binary.
    - _Default:_ `denort` derived from `denoPackage`
    - Don't use `pkgs.deno` for this, since that is the full Deno CLI, with all the development tooling.
    - If you're cross compiling, this needs to be the `denort` of the `hostPlatform`.

**NOTE**:

The binary will be dynamically linked and not executable on NixOS without [nix-ld](https://github.com/nix-community/nix-ld)
or [other methods](https://unix.stackexchange.com/questions/522822/different-methods-to-run-a-non-nixos-executable-on-nixos).

```nix
# configuration.nix
{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    glibc
    gcc-unwrapped
  ];
}
```

<details>

<summary>
Example
</summary>

##### example binary build

```nix
{ buildDenoPackage, nix-gitignore }:
buildDenoPackage {
  pname = "myPackage";
  version = "0.1.0";
  denoDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
  src = nix-gitignore.gitignoreSource [ ] ./.;
  binaryEntrypointPath = "main.ts";
}
```

</details>

#### Create artifacts in the build

Instead of compiling to a binary, `deno task` can be executed inside the build
to produce some artifact, which can then be copied out in the `installPhase`.

Related options:

- *`denoTaskScript`* (String; optional): The task in `deno.json` that's executed with `deno task`.
    - _Default:_ `"build"`
- *`denoTaskFlags`* (Array of strings; optional): The flags passed to `deno task [denoTaskFlags] ${denoTaskScript} [extraTaskFlags]`.
- *`extraTaskFlags`* (Array of strings; optional): The flags passed to `deno task [denoTaskFlags] ${denoTaskScript} [extraTaskFlags]`.
- *`denoTaskPrefix`* (String; optional): An unquoted string injected before `deno task`.
- *`denoTaskSuffix`* (String; optional): An unquoted string injected after `deno task` and all its flags. For example to pipe stdout to a file.

<details>

<summary>
Example
</summary>

##### example artifact build

`deno.json`

```json
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

</details>

#### Workspaces

Deno's workspaces are supported.

To make them work, the whole project needs to be added as source, since the `deno.lock`
is always in the root of the project and contains all dependencies.

This means a build with only the required dependencies of a workspace is not possible.
Also, the `denoDepsHash` for all workspaces is the same, since they
all share the same dependencies.

When [running a task inside the build](#javascript-buildDenoPackage-artifacts-in-build),
`denoWorkspacePath` can be used to let the task run inside a workspace.

When [compiling to a binary](#javascript-buildDenoPackage-compile-to-binary),
`binaryEntrypointPath` is prefixed by `denoWorkspacePath`.

Related options:

- *`denoWorkspacePath`* (String; optional): The path to a workspace.

<details>

<summary>
Example
</summary>

##### example workspaces

```nix
{ buildDenoPackage, nix-gitignore }:
rec {
  sub1 = buildDenoPackage {
    pname = "sub1";
    version = "0.1.0";
    denoDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    src = nix-gitignore.gitignoreSource [ ] ./.;
    denoWorkspacePath = "./sub1";
    denoTaskFlags = [
      "--text"
      "sub1"
    ];
    denoTaskSuffix = ">out.txt";
    installPhase = ''
      cp out.txt $out
    '';
  };
  sub2 = buildDenoPackage {
    # Note that we are reusing denoDeps and src,
    # since they must be the same for both workspaces.
    inherit (sub1) denoDeps src;
    pname = "sub2";
    version = "0.1.0";
    denoWorkspacePath = "./sub2";
    binaryEntrypointPath = "./main.ts";
  };
}
```

</details>

#### Other Options

- *`denoDir`* (String; optional): `DENO_DIR` will be set to this value for all `deno` commands.

- *`denoFlags`* (Array of string; optional): The flags passed to all `deno` commands.

- *`denoPackage`* (Derivation; optional): The Deno CLI used for all `deno` commands inside the build.
    - _Default:_ `pkgs.deno`

### fetchDenoDeps standalone

`fetchDenoDeps` allows you to create a derivation containing all dependencies needed to run a [Deno](https://deno.com/) package.

### Usage

1. Define the derivation for the dependencies like this:

    ```nix
    { fetchDenoDeps }:
    {
      my-deps = fetchDenoDeps {
        name = "<name>";
        denoLock = ./path/to/lockfile;
        hash = "<hash>";
      };
    }
    ```


2. Use the deps build like this (it's easier to use `buildDenoPackage`, see [below](#buildDenoPackage)):

    ```nix
    { stdenvNoCC, my-deps }:
    {
      my-deno-package = stdenvNoCC.mkDerivation {
        name = "<name>";
        src = ./path/to/project/src;
        buildPhase = ''
          # copy the deps to the required location
          cp -r --no-preserve=mode ${my-deps.denoDeps}/.deno ./
          cp -r --no-preserve=mode ${my-deps.denoDeps}/vendor ./

          # Now you can run the project using deps
          # you need to activate [deno's vendor feature](https://docs.deno.com/runtime/fundamentals/modules/#vendoring-remote-modules)
          # you need to use the `$DENO_DIR` env var, to point deno to the correct local cache
          DENO_DIR=./.deno deno run --cached-only --frozen --vendor ./main.ts
        '';
        installPhase = ''
          cp -r ./path/to/build/result $out
        '';
      };
    }
    ```

    Or like this:

    ```sh
    nix-build ./default.nix -A my-deps.denoDeps
    cp -r --no-preserve=mode ./result/.deno ./
    cp -r --no-preserve=mode ./result/vendor ./
    DENO_DIR=./.deno deno run --cached-only --frozen --vendor ./main.ts
    ```

#### Missing deno features

There are a number of features that are supported by the Deno CLI, but not by this build helper, yet.
If a package uses one of those features, this build helper can't be used.

- [`nodeModulesDir`](https://docs.deno.com/runtime/fundamentals/node/#node_modules) &
[`--allow-scripts`](https://docs.deno.com/runtime/reference/CLI/add/#options-allow-scripts)
- [private HTTPS repositories](https://docs.deno.com/runtime/fundamentals/modules/#private-repositories)
- [`.npmrc`](https://docs.npmjs.com/CLI/v8/configuring-npm/npmrc)
