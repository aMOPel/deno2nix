

.PHONY: reset-hashes
reset-hashes:
	# reset deps hashes
	find . -type f -name "*.nix" -exec sed -i -E 's|denoDepsHash[[:space:]]*=[[:space:]]*"sha256-[^"]*";|denoDepsHash = "";|g' {} +

.PHONY: tests
tests:
	nix build -f . checks.tests.sub1.denoDeps
	nix build -f . checks.tests.sub1.denoDeps --rebuild
	nix build -f . checks.tests.sub2.denoDeps
	nix build -f . checks.tests.sub2.denoDeps --rebuild
	nix build -f . checks.tests.sub1Binary.denoDeps
	nix build -f . checks.tests.sub1Binary.denoDeps --rebuild
	nix build -f . checks.tests.readma-cli-linux.denoDeps
	nix build -f . checks.tests.readma-cli-linux.denoDeps --rebuild
	nix build -f . checks.tests.readma-cli-linux.denoDeps
	nix build -f . checks.tests.readma-cli-linux.denoDeps --rebuild
	nix build -f . checks.tests.fresh-init-cli-linux.denoDeps
	nix build -f . checks.tests.fresh-init-cli-linux.denoDeps --rebuild
	nix build -f . checks.tests.with-npm-linux.denoDeps
	nix build -f . checks.tests.with-npm-linux.denoDeps --rebuild
	nix build -f . checks.tests.without-npm-linux.denoDeps
	nix build -f . checks.tests.without-npm-linux.denoDeps --rebuild

	nix build -f . checks.tests.sub1
	nix build -f . checks.tests.sub1 --rebuild
	nix build -f . checks.tests.sub2
	nix build -f . checks.tests.sub2 --rebuild
	nix build -f . checks.tests.sub1Binary
	# nix build -f . checks.tests.sub1Binary --rebuild
	nix build -f . checks.tests.readma-cli-linux
	# nix build -f . checks.tests.readma-cli-linux --rebuild
	nix build -f . checks.tests.readma-cli-linux
	# nix build -f . checks.tests.readma-cli-linux --rebuild
	nix build -f . checks.tests.fresh-init-cli-linux
	# nix build -f . checks.tests.fresh-init-cli-linux --rebuild
	nix build -f . checks.tests.with-npm-linux
	# nix build -f . checks.tests.with-npm-linux --rebuild
	nix build -f . checks.tests.without-npm-linux
	nix build -f . checks.tests.without-npm-linux --rebuild

