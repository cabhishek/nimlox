import os, strutils, utils, token, tokenKind

proc reportError*(line: int, where: string, msg: string) =
  display("Error: $1" % msg)
  display(indent("Line: $1 Char: $2" % [$line, where], count=2))

proc reportError*(token: Token, message: string) =
  if token.kind == tkEof:
    reportError(token.line, " at end", message)
  else:
    reportError(token.line, "at '$1'" % [token.lexeme], message)
