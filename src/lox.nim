import os, strutils, lexer, token, parser, astprinter, utils

const Prompt = ">>> "

# Starts scanning the source code
proc run(source: string) =
  var lex = newLexer(source)
  let
    tokens = lex.scanTokens()
    printer = AstPrinter()
  var
    parser = newParser(tokens)
    expression = parser.parse()

  display(printer.print(expression))

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
    quit("Usage: lox [script]")
  elif params.len == 1:
    runFile(params[0])
  else:
    runPrompt()
