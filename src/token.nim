import strutils, tokenKind

type
  Token* = object
    line*: int
    lexeme* : string
    case kind*: Tokenkind
      of tkNumber: floatVal*: float
      else: strVal*: string

# Stringify token
proc `$`*(tok: Token): string =
  return "$1 $2 $3" % [$tok.kind, tok.lexeme, $tok.line]
