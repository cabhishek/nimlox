app := nimlox

.PHONY: tests

sample:
	@nim -r --verbosity:0 c --o:bin/sample src/main.nim sample.lox

repl:
	@nim -r --verbosity:0 c --o:bin/main src/main.nim

test: tests

tests:
	@nim -r --verbosity:0 c --o:bin/testAll tests/all.nim

print-%: ; @echo $* = $($*)
