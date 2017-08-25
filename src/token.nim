import strutils, tokenKind

type
  Token* = object
    line*: int
    lexeme* : string
    case kind*: Tokenkind
      of STRING: sValue*: string
      of NUMBER: fValue*: float
      else: discard

# Stringify token
proc `$`*(t: Token): string =
  return "$1 $2 $3" % [$t.kind, t.lexeme, $t.line]
