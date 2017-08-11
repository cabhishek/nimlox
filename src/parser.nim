import strutils, token, tokenType, literalKind, expression, utils, errors

type
  ParserError = ref object of Exception
  Parser= object
    current*: int
    tokens*: seq[Token]

proc unary(p: var Parser): Expression # forward declare

proc error(p: Parser, token: Token, message: string): ParserError =
  reportError(token, message)
  return ParserError()

proc previous(p: Parser): Token = p.tokens[p.current - 1]

proc peek(p: Parser): Token = p.tokens[p.current]

proc isAtEnd(p: Parser): bool = p.peek().tokenType == TokenType.EOF

proc advance(p: var Parser): Token {.discardable.} =
  if not p.isAtEnd(): p.current += 1
  return p.previous()

proc check(p: Parser, tokenType: TokenType): bool =
  if p.isAtEnd(): return false
  return p.peek().tokenType == tokenType

proc match(p: var Parser, types: varargs[TokenType]): bool =
  for tokenType in types:
    if p.check(tokenType):
      p.advance()
      return true
  return false

proc multiplication(p: var Parser): Expression =
  var expr: Expression = p.unary()
  while p.match(TokenType.SLASH, TokenType.STAR):
    let
      operator: Token = p.previous()
      right: Expression = p.unary()
      expr = Binary(left: expr, operator: operator, right: right)
  return expr

proc addition(p: var Parser): Expression =
  var expr: Expression = p.multiplication()
  while p.match(TokenType.MINUS, TokenType.PLUS):
    let
      operator: Token = p.previous()
      right: Expression = p.multiplication()
      expr = Binary(left: expr, operator: operator, right: right)
  return expr

proc comparison(p: var Parser): Expression =
  var expr: Expression = p.addition()
  while p.match(TokenType.GREATER,
                   TokenType.GREATER_EQUAL,
                   TokenType.LESS,
                   TokenType.LESS_EQUAL):
    let
      operator: Token = p.previous()
      right: Expression = p.addition()
      expr = Binary(left: expr, operator: operator, right: right)
  return expr

proc equality(p: var Parser): Expression =
  var expr: Expression = p.comparison()
  while p.match(TokenType.BANG_EQUAL, TokenType.EQUAL_EQUAL):
    let
      operator: Token = p.previous()
      right: Expression = p.comparison()
      expr = Binary(left: expr, operator: operator, right: right)
  return expr

proc expression(p: var Parser): Expression = return p.equality()

proc consume(p: var Parser,
             tokenType: TokenType,
             message: string): Token {.raises: ParserError.} =
  if p.check(tokenType): return p.advance()
  raise p.error(p.peek(), message)

proc primary(p: var Parser): Expression =
  if p.match(TokenType.FALSE):
    result = Literal(kind: LiteralKind.BOOLEAN, bValue: false)
  if p.match(TokenType.TRUE):
    result = Literal(kind: LiteralKind.BOOLEAN, bValue: true)
  if p.match(TokenType.NIL):
    # little hack to get around Nim's type system (here string type is set to nil)
    result = Literal(kind: LiteralKind.NIL, value: nil)

  if p.match(TokenType.NUMBER):
    result = Literal(kind: LiteralKind.NUMBER, fValue: p.previous().fValue)

  if p.match(TokenType.STRING):
    result = Literal(kind: LiteralKind.STRING, svalue: p.previous().sValue)

  if p.match(TokenType.LEFT_PAREN):
    let expr = p.expression()
    discard p.consume(TokenType.RIGHT_PAREN, "Expected ')' after expression")
    result = Grouping(expression: expr)

proc unary(p: var Parser): Expression =
  if p.match(TokenType.BANG, TokenType.MINUS):
    let
      operator: Token = p.previous()
      right: Expression = p.unary()
    return Unary(operator: operator, right: right)
  return p.primary()

proc synchronize(p: var Parser) {.discardable.} =
  p.advance()
  while not p.isAtEnd():
    if p.previous().tokenType == TokenType.SEMICOLON: return
    case p.peek().tokenType:
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
    p.advance()

proc parse*(p: var Parser): Expression =
  try:
    return p.expression()
  except ParserError:
      p.synchronize()
      return nil

proc newParser*(tokens: seq[Token]): Parser =
  # Create a new Parser instance
  return Parser(
    current: 0,
    tokens: tokens
  )
