 import os, strutils, lexer, token, parser, astprinter, utils

# Start scanning lox source code
template exec(source: string) =
  var lex = newLexer(source)
  let
    tokens = lex.scanTokens()
    printer = AstPrinter()
  var
    parser = newParser(tokens)
    expression = parser.parse()

  display(printer.print(expression))

template execFile(filename: string) =
  exec(readFile(filename))

template startRepl() =
  while true:
    display(">>> ", newLine=false)
    exec(readline(stdin))

when isMainModule:
  let params: seq[string] = commandLineParams()
  if params.len > 1:
    quit("Usage: lox [filename] or [expression]")
  elif params.len == 1:
    execFile(params[0])
  else:
    startRepl()
