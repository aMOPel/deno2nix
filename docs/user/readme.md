### fetchDenoDeps {#javascript-fetchDenoDeps}

`fetchDenoDeps` allows you to create a derivation containing all dependencies needed to run a [Deno](https://deno.com/) package.

### Usage {#javascript-fetchDenoDeps-usage}

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


2. Use the deps build like this:

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

#### Missing deno features {#javascript-fetchDenoDeps-missing-deno-features}

There are a number of features that are supported by the Deno CLI, but not by this build helper, yet.
If a package uses one of those features, this build helper can't be used.

- [`nodeModulesDir`](https://docs.deno.com/runtime/fundamentals/node/#node_modules) &
[`--allow-scripts`](https://docs.deno.com/runtime/reference/CLI/add/#options-allow-scripts)
- [private HTTPS repositories](https://docs.deno.com/runtime/fundamentals/modules/#private-repositories)
- [`.npmrc`](https://docs.npmjs.com/CLI/v8/configuring-npm/npmrc)

##### Type files {#javascript-fetchDenoDeps-missing-deno-features-type-files}

Additionally fetched type files are not fetched and don't end up in the derivation.

This includes files imported with:

- [@ts-types/@deno-types](https://docs.deno.com/runtime/reference/ts_config_migration/#providing-types-when-importing)
- [triple slash directive](https://docs.deno.com/runtime/reference/ts_config_migration/#triple-slash-directive)
- [deno.json's compilerOption.types](https://docs.deno.com/runtime/reference/ts_config_migration/#supplying-%22types%22-in-deno.json)
- [`X-Typescript-Types: <url>` response header](https://docs.deno.com/runtime/fundamentals/typescript/#providing-types-for-http-modules).

You can still run `deno run` to run the project.

But you will get an error when running `deno check` or `deno compile`.
In that case, you need to add the `--no-check` flag.

