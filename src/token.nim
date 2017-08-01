import strutils, tokenType

type
  Token* = object
    line*: int
    lexeme* : string
    case tokenType*: TokenType
      of TokenType.STRING: strValue*: string
      of TokenType.NUMBER: floatValue*: float
      else: discard

# Stringify token
proc `$`*(t: Token): string =
  return "$1 $2 $3" % [$t.tokenType, t.lexeme, $t.line]
