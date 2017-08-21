app := nimlox

.all: repl
.PHONY: tests

sample:
	@nim sample lox

repl:
	@nim repl lox

test: tests
tests:
	@nim test lox

print-%: ; @echo $* = $($*)
