import token, expression

type
  Parser= object
    current*: int
    tokens*: seq[Token]

proc newParser*(tokens: seq[Token]): Parser =
  # Create a new Parser instance
  return Parser(
    current: 0,
    tokens: tokens
  )
