import os, strutils, lexer, token, expr, parser, interpreter, utils, loxerror, typetraits

# Start scanning lox source code
proc exec(source: string) =
  var lex = newLexer(source)
  let
    tokens = lex.scanTokens()
    interpreter = Interpreter()
  var
    parser = newParser(tokens)
    expr = parser.parse()

  if expr.hasError: return

  let result = interpreter.interpret(expr)
  if result.kind == loxException: return

  display($result)

template execFile(filename: string) =
  exec(readFile(filename))

template startRepl() =
  while true:
    display("lox> ", newLine=false)
    exec(readline(stdin))

when isMainModule:
  let params: seq[string] = commandLineParams()
  if params.len > 1:
    quit("Usage: lox [filename]")
  elif params.len == 1:
    execFile(params[0])
  else:
    startRepl()
