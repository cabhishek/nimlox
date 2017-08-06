import strutils, token, tokenType, expression, utils, errors

type
  ParserError = ref object of Exception
  Parser= object
    current*: int
    tokens*: seq[Token]

proc unary(self: var Parser): Expression # forward declare

proc error(self: Parser, token: Token, message: string): ParserError =
  reportError(token, message)
  return ParserError()

proc previous(self: Parser): Token = self.tokens[self.current - 1]

proc peek(self: Parser): Token = self.tokens[self.current]

proc isAtEnd(self: Parser): bool = self.peek().tokenType == TokenType.EOF

proc advance(self: var Parser): Token {.discardable.} =
  if not self.isAtEnd(): self.current += 1
  return self.previous()

proc check(self: Parser, tokenType: TokenType): bool =
  if self.isAtEnd(): return false
  return self.peek().tokenType == tokenType

proc match(self: var Parser, types: varargs[TokenType]): bool =
  for tokenType in types:
    if self.check(tokenType):
      self.advance()
      return true
  return false

proc multiplication(self: var Parser): Expression =
  var expr: Expression = self.unary()
  while self.match(TokenType.SLASH, TokenType.STAR):
    let
      operator: Token = self.previous()
      right: Expression = self.unary()
      expr = Binary(left: expr, operator: operator, right: right)
  return expr

proc addition(self: var Parser): Expression =
  var expr: Expression = self.multiplication()
  while self.match(TokenType.MINUS, TokenType.PLUS):
    let
      operator: Token = self.previous()
      right: Expression = self.multiplication()
      expr = Binary(left: expr, operator: operator, right: right)
  return expr

proc comparison(self: var Parser): Expression =
  var expr: Expression = self.addition()
  while self.match(TokenType.GREATER,
                   TokenType.GREATER_EQUAL,
                   TokenType.LESS,
                   TokenType.LESS_EQUAL):
    let
      operator: Token = self.previous()
      right: Expression = self.addition()
      expr = Binary(left: expr, operator: operator, right: right)
  return expr

proc equality(self: var Parser): Expression =
  var expr: Expression = self.comparison()
  while self.match(TokenType.BANG_EQUAL, TokenType.EQUAL_EQUAL):
    let
      operator: Token = self.previous()
      right: Expression = self.comparison()
      expr = Binary(left: expr, operator: operator, right: right)
  return expr

proc expression(self: var Parser): Expression = return self.equality()

proc consume(self: var Parser,
             tokenType: TokenType,
             message: string): Token {.raises: ParserError.} =
  if self.check(tokenType): return self.advance()
  raise self.error(self.peek(), message)

proc primary(self: var Parser): Expression =
  if self.match(TokenType.FALSE):
    result = Literal(value: "false")
  if self.match(TokenType.TRUE):
    result = Literal(value: "true")
  if self.match(TokenType.NIL):
    result = Literal(value: "null")

  if self.match(TokenType.NUMBER):
    result = Literal(value: $self.previous().floatValue)

  if self.match(TokenType.STRING):
    result = Literal(value: self.previous().strValue)

  if self.match(TokenType.LEFT_PAREN):
    let expr = self.expression()
    discard self.consume(TokenType.RIGHT_PAREN, "Expected ')' after expression")
    result = Grouping(expression: expr)

proc unary(self: var Parser): Expression =
  if self.match(TokenType.BANG, TokenType.MINUS):
    let
      operator: Token = self.previous()
      right: Expression = self.unary()
    return Unary(operator: operator, right: right)
  return self.primary()

proc synchronize(self: var Parser) {.discardable.} =
  self.advance()

  while not self.isAtEnd():
    if self.previous().tokenType == TokenType.SEMICOLON: return

    case self.peek().tokenType:
      of TokenType.CLASS,
         TokenType.FUN,
         TokenType.VAR,
         TokenType.FOR,
         TokenType.IF,
         TokenType.WHILE,
         TokenType.PRINT,
         TokenType.RETURN:
        return
      else: discard

    self.advance()

proc parse*(self: var Parser): Expression =
  try:
    return self.expression()
  except ParserError:
      self.synchronize()
      return nil

proc newParser*(tokens: seq[Token]): Parser =
  # Create a new Parser instance
  return Parser(
    current: 0,
    tokens: tokens
  )
