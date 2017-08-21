import ospaths, strutils

template runTest(name: string) =
  withDir thisDir():
    mkDir "bin"
    --r
    --verbosity:0
    --hints:off
    --o:"""bin/""" name
    --path:"""src"""
    setCommand "c", "tests/" & name & ".nim"

task test, "Run lox tests":
  runTest "all"

task repl, "Run lox repl":
  --r
  --verbosity:0
  --hints:off
  --o:"""bin/lox"""
  setCommand "c", "src/lox.nim"

task sample, "Run sample lox file":
  exec("nim -r --verbosity:0 c --o:bin/sample src/lox.nim sample.lox")

