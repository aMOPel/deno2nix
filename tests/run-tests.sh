#!/usr/bin/env bash

set -e

# fetchDenoDeps
nix build -f . checks.tests.fetchDenoDeps-integration-tests
nix build -f . checks.tests.fetchDenoDeps-e2e-tests.just-jsr-linux
nix build -f . checks.tests.fetchDenoDeps-e2e-tests.with-https-linux
nix build -f . checks.tests.fetchDenoDeps-e2e-tests.with-https-and-npm-linux

# buildDenoPackage-e2e-tests deno deps
nix build -f . checks.tests.buildDenoPackage-e2e-tests.sub1.denoDeps
nix build -f . checks.tests.buildDenoPackage-e2e-tests.sub1.denoDeps --rebuild
nix build -f . checks.tests.buildDenoPackage-e2e-tests.sub2.denoDeps
nix build -f . checks.tests.buildDenoPackage-e2e-tests.sub2.denoDeps --rebuild
nix build -f . checks.tests.buildDenoPackage-e2e-tests.sub1Binary.denoDeps
nix build -f . checks.tests.buildDenoPackage-e2e-tests.sub1Binary.denoDeps --rebuild
nix build -f . checks.tests.buildDenoPackage-e2e-tests.readma-cli-linux.denoDeps
nix build -f . checks.tests.buildDenoPackage-e2e-tests.readma-cli-linux.denoDeps --rebuild
nix build -f . checks.tests.buildDenoPackage-e2e-tests.fresh-init-cli-linux.denoDeps
nix build -f . checks.tests.buildDenoPackage-e2e-tests.fresh-init-cli-linux.denoDeps --rebuild
nix build -f . checks.tests.buildDenoPackage-e2e-tests.just-jsr-linux.denoDeps
nix build -f . checks.tests.buildDenoPackage-e2e-tests.just-jsr-linux.denoDeps --rebuild
nix build -f . checks.tests.buildDenoPackage-e2e-tests.with-https-and-npm-linux.denoDeps
nix build -f . checks.tests.buildDenoPackage-e2e-tests.with-https-and-npm-linux.denoDeps --rebuild
nix build -f . checks.tests.buildDenoPackage-e2e-tests.with-https-linux.denoDeps
nix build -f . checks.tests.buildDenoPackage-e2e-tests.with-https-linux.denoDeps --rebuild

# buildDenoPackage-e2e-tests
nix build -f . checks.tests.buildDenoPackage-e2e-tests.sub1
nix build -f . checks.tests.buildDenoPackage-e2e-tests.sub1 --rebuild
nix build -f . checks.tests.buildDenoPackage-e2e-tests.sub2
nix build -f . checks.tests.buildDenoPackage-e2e-tests.sub2 --rebuild
nix build -f . checks.tests.buildDenoPackage-e2e-tests.sub1Binary
# nix build -f . checks.tests.buildDenoPackage-e2e-tests.sub1Binary --rebuild
nix build -f . checks.tests.buildDenoPackage-e2e-tests.readma-cli-linux
# nix build -f . checks.tests.buildDenoPackage-e2e-tests.readma-cli-linux --rebuild
nix build -f . checks.tests.buildDenoPackage-e2e-tests.fresh-init-cli-linux
# nix build -f . checks.tests.buildDenoPackage-e2e-tests.fresh-init-cli-linux --rebuild
nix build -f . checks.tests.buildDenoPackage-e2e-tests.with-https-and-npm-linux
# nix build -f . checks.tests.buildDenoPackage-e2e-tests.with-https-and-npm-linux --rebuild
nix build -f . checks.tests.buildDenoPackage-e2e-tests.with-https-linux
nix build -f . checks.tests.buildDenoPackage-e2e-tests.with-https-linux --rebuild
nix build -f . checks.tests.buildDenoPackage-e2e-tests.just-jsr-linux
nix build -f . checks.tests.buildDenoPackage-e2e-tests.just-jsr-linux --rebuild

# compare output from binary and artifact build
rm -f output1.txt output2.txt
cp $(nix-build . -A checks.tests.buildDenoPackage-e2e-tests.sub1) output1.txt
$(nix-build . -A checks.tests.buildDenoPackage-e2e-tests.sub1Binary)/bin/* --text sub1 >output2.txt
diff output1.txt output2.txt

# installation test
nix build -f . checks.tests.installation-test
nix build -f . checks.tests.installation-test --rebuild
