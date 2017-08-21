app := nimlox

.all: repl
.PHONY: tests

sample:
	@nim -r --verbosity:0 c --o:bin/sample src/lox.nim sample.lox

repl:
	@nim -r --verbosity:0 c --o:bin/lox src/lox.nim

test: tests
tests:
	@nim -r --verbosity:0 c --o:bin/testAll tests/all.nim

print-%: ; @echo $* = $($*)
