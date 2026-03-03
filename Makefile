.PHONY: test lint

lint:
	bash -n bin/sfb lib/*.sh

test:
	bats tests/sfb.bats
