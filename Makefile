.PHONY: format lint test

format:
	stylua lua colors tests

lint:
	stylua --check lua colors tests
	find lua colors tests -type f -name '*.lua' -exec luac -p {} +

test:
	sh tests/run.sh
