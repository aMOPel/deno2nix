### buildDenoPackage {#javascript-buildDenoPackage}

`buildDenoPackage` allows you to package [Deno](https://deno.com/) projects in Nixpkgs without the use of an auto-generated dependencies file (as used in [node2nix](#javascript-node2nix)).
It works by utilizing Deno's cache functionality -- creating a reproducible cache that contains the dependencies of a project, and pointing Deno to it.

#### buildDenoDeps {#javascript-buildDenoPackage-buildDenoDeps}

For every `buildDenoPackage`, first, a [fixed output derivation](https://nix.dev/manual/nix/2.18/language/advanced-attributes.html#adv-attr-outputHash) is
created with all the dependencies mentioned in the `deno.lock`.
This works as follows:
1. They are installed using `deno install`.
1. All non-reproducible data is pruned.
1. The directories `.deno`, `node_modules` and `vendor` are copied to `$out`.
1. The output of the FOD is checked against the `denoDepsHash`.
1. The output is copied into the build of `buildDenoPackage`, which is not an FOD.
1. The dependencies are installed again using `deno install`, this time from the local cache only.

The `buildDenoDeps` derivation is in `passthru`, so it can be accessed from a `buildDenoPackage` derivation with `.denoDeps`

Related options:

*`denoDepsHash`* (String)

: The output hash of the `buildDenoDeps` fixed output derivation.

*`denoInstallFlags`* (Array of strings; optional)

: The Flags passed to `deno install`.

: _Default:_ `[ "--allow-scripts" "--frozen" "--cached-only" ]` for `buildDenoPackage`
: _Default:_ `[ "--allow-scripts" "--frozen" ]` for `buildDenoDeps` (`"--cached-only"` is filtered out)

::: {.tip}
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

:::

#### Private registries {#javascript-buildDenoPackage-private-registries}
There are currently 2 options, which enable the use of private registries in a `buildDenoPackage` derivation.

*`denoDepsImpureEnvVars`* (Array of strings; optional)

: Names of impure environment variables passed to the `buildDenoDeps` derivation. They are forwarded to `deno install`.

: _Example:_ `[ "NPM_TOKEN" ]`

: It can be used to set tokens for private NPM registries (in a `.npmrc` file).

: In a single-user installation of Nix, you can put the variables into the environment, when running the nix build.

: In multi-user installations of Nix, it's necessary to set the environment variables in the nix-daemon, probably with systemd.

:::{.example}

##### configure nix-daemon {#javascript-buildDenoPackage-private-registries-daemon-example}
In NixOS:

```nix
# configuration.nix
{
  config,
  lib,
  pkgs,
  ...
}:
{
  systemd.services.nix-daemon.environment.NPM_TOKEN = "<token>";
}
```

In other Linux distributions use

```
$ sudo systemctl edit nix-daemon
$ sudo systemctl cat nix-daemon
$ sudo systemctl restart nix-daemon
```

:::

*`denoDepsInjectedEnvVars`* (Attrset; optional)

: Environment variables as key value pairs. They are forwarded to `deno install`.

: _Example:_ `{ "NPM_TOKEN" = "<token>"; }`

: It can be used to set tokens for private NPM registries (in a `.npmrc` file).
You could pass these tokens from the Nix CLI with `--arg`,
however this can hurt the reproducibility of your builds and such an injected
token will also need to be injected in every build that depends on this build.

:::{.example}

##### example `.npmrc` {#javascript-buildDenoPackage-private-registries-npmrc-example}

```ini
@<scope>:registry=https://<domain>/<path to private registry>
//<domain>/<path to private registry>:_authToken=${NPM_TOKEN}
```

:::

::: {.caution}

Hardcoding a token into your NixOS configuration or some other nix build, will as a consequence write that token into `/nix/store`, which is considered world readable.

:::

::: {.note}
Neither approach is ideal. For `buildNpmPackage`, there exists a third
option called `sourceOverrides`, which allows the user to inject Nix packages into
the output `node_modules` folder.
Since a Nix build implicitly uses the SSH keys of the machine,
this offers a third option to access private packages.
But this creates the requirement, that the imported package is packaged with nix first,
and that the source code can be retrieved with SSH.
This is possible for Deno, too, albeit it not
completely analogous to `buildNpmPackage`'s solution.
However, it has not been implemented yet.
:::

#### Compile to binary {#javascript-buildDenoPackage-compile-to-binary}

It's possible to compile a Deno project to a single binary using `deno compile`.
The binary will be named like the `.name` property in `deno.json`, if available,
or the `name` attribute of the derivation.

:::{.caution}
When using packages with a `npm:` specifier, the resulting binary will not be reproducible.
See [this issue](https://github.com/denoland/deno/issues/29619) for more information.
:::

Related options:

*`hostPlatform`* (String; optional)

: The [host platform](#ssec-cross-platform-parameters) the binary is built for.

: _Default:_ `builtins.currentSystem`.

: _Supported values:_
  - `"x86_64-darwin"`
  - `"aarch64-darwin"`
  - `"x86_64-linux"`
  - `"aarch64-linux"`

*`denoCompileFlags`* (Array of string; optional)

: Flags passed to `deno compile [denoTaskFlags] ${binaryEntrypointPath} [extraCompileFlags]`.

*`extraCompileFlags`* (Array of string; optional)

: Flags passed to `deno compile [denoTaskFlags] ${binaryEntrypointPath} [extraCompileFlags]`.

*`binaryEntrypointPath`* (String or null; optional)

: If not `null`, a binary is created using the specified path as the entry point.
The binary is copied to `$out/bin` in the `installPhase`.

: _Default:_ `null`

: It's prefixed by `denoWorkspacePath`.

*`denortPackage`* (Derivation; optional)

: The package used as the Deno runtime, which is bundled with the JavaScript code to create the binary.

: _Default:_ `pkgs.denort`

: Don't use `pkgs.deno` for this, since that is the full Deno CLI, with all the development tooling.

: If you're cross compiling, this needs to be the `denort` of the `hostPlatform`.

::: {.note}
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

:::

:::{.example}

##### example binary build {#javascript-buildDenoPackage-compile-to-binary-example}

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

:::

#### Create artifacts in the build {#javascript-buildDenoPackage-artifacts-in-build}

Instead of compiling to a binary, `deno task` can be executed inside the build
to produce some artifact, which can then be copied out in the `installPhase`.

Related options:

*`denoTaskScript`* (String; optional)

: The task in `deno.json` that's executed with `deno task`.

: _Default:_ `"build"`

*`denoTaskFlags`* (Array of strings; optional)

: The flags passed to `deno task [denoTaskFlags] ${denoTaskScript} [extraTaskFlags]`.

*`extraTaskFlags`* (Array of strings; optional)

: The flags passed to `deno task [denoTaskFlags] ${denoTaskScript} [extraTaskFlags]`.

*`denoTaskPrefix`* (String; optional)

: An unquoted string injected before `deno task`.

*`denoTaskSuffix`* (String; optional)

: An unquoted string injected after `deno task` and all its flags. For example to pipe stdout to a file.

:::{.example}

##### example artifact build {#javascript-buildDenoPackage-artifacts-in-build-example}

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

:::

#### Workspaces {#javascript-buildDenoPackage-workspaces}

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

*`denoWorkspacePath`* (String; optional)

: The path to a workspace.

:::{.example}

##### example workspaces {#javascript-buildDenoPackage-workspaces-example}

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

:::

#### Other Options {#javascript-buildDenoPackage-other-options}

*`denoDir`* (String; optional)

: `DENO_DIR` will be set to this value for all `deno` commands.

*`denoFlags`* (Array of string; optional)

: The flags passed to all `deno` commands.

*`denoPackage`* (Derivation; optional)

: The Deno CLI used for all `deno` commands inside the build.

: _Default:_ `pkgs.deno`


