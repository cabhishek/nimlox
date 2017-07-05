import os, strutils, scanner, token, utils

const Prompt = ">>> "

# Starts scanning the source code
proc run(source: string) =
  var s = newScanner(source)
  let tokens = s.scanTokens()
  for token in tokens:
    display(indent($token, count=2))

  display("Total tokens: $1 lines: $2" % [$tokens.len, $s.line])

proc runFile(filename: string) =
  run(readFile(filename))

# REPL interface for lox
proc runPrompt() =
  while true:
    display(Prompt, newLine=false)
    run(stdin.readline())

when isMainModule:
  let params: seq[string] = commandLineParams()
  if params.len > 1:
    display("Usage: lox [script]")
    quit(1)
  elif params.len == 1:
    runFile(params[0])
  else:
    runPrompt()
