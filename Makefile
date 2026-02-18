.PHONY: reset-hashes
reset-hashes:
	# reset deps hashes
	find . -type f -name "*.nix" -exec sed -i -E 's|denoDepsHash[[:space:]]*=[[:space:]]*"sha256-[^"]*";|denoDepsHash = "";|g' {} +

.PHONY: tests
tests:
	bash ./tests/run-tests.sh
