import ospaths, strutils, strformat

template runTest(name: string) =
  withDir thisDir():
    mkDir "bin"
    exec "nim c -r --o:bin/$1 tests/$1.nim" % name
    setCommand "nop"  
  
task tests, "Run lox tests":
  runTest "all"

task repl, "Run lox repl":
  exec "nim c -r --o:bin/lox src/lox.nim"
  setCommand "nop"  

task sample, "Run sample lox file":
  exec "nim -r --verbosity:0 c --o:bin/sample src/lox.nim sample.lox"

