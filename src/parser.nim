import strutils, token, tokenKind, literalKind, expression, utils, errors

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

proc isAtEnd(p: Parser): bool = p.peek().kind == tkEof

proc advance(p: var Parser): Token {.discardable.} =
  if not p.isAtEnd(): p.current += 1
  return p.previous()

proc check(p: Parser, tokenKind: TokenKind): bool =
  if p.isAtEnd(): return false
  return p.peek().kind == tokenKind

proc match(p: var Parser, types: varargs[TokenKind]): bool =
  for tokenKind in types:
    if p.check(tokenKind):
      p.advance()
      return true
  return false

proc multiplication(p: var Parser): Expression =
  var expr: Expression = p.unary()
  while p.match(tkSlash, tkStar):
    let
      operator: Token = p.previous()
      right: Expression = p.unary()
    expr = Binary(left: expr, operator: operator, right: right)
  return expr

proc addition(p: var Parser): Expression =
  var expr: Expression = p.multiplication()
  while p.match(tkMinus, tkPlus):
    let
      operator: Token = p.previous()
      right: Expression = p.multiplication()
    expr = Binary(left: expr, operator: operator, right: right)
  return expr

proc comparison(p: var Parser): Expression =
  var expr: Expression = p.addition()
  while p.match(tkGreater,
                tkGreaterEqual,
                tkLess,
                tkLessEqual):
    let
      operator: Token = p.previous()
      right: Expression = p.addition()
    expr = Binary(left: expr, operator: operator, right: right)
  return expr

proc equality(p: var Parser): Expression =
  var expr: Expression = p.comparison()
  while p.match(tkBangEqual, tkEqualEqual):
    let
      operator: Token = p.previous()
      right: Expression = p.comparison()
    expr = Binary(left: expr, operator: operator, right: right)
  return expr

proc expression(p: var Parser): Expression = return p.equality()

proc consume(p: var Parser,
             tokenKind: TokenKind,
             message: string): Token =
  if p.check(tokenKind): return p.advance()
  raise p.error(p.peek(), message)

proc primary(p: var Parser): Expression =
  if p.match(tkFalse):
    result = Literal(kind: litBool, boolVal: false)
  if p.match(tkTrue):
    result = Literal(kind: litBool, boolVal: true)
  if p.match(tkNil):
    # little hack to get around Nim's type system (here string type is set to nil)
    result = Literal(kind: litNil)

  if p.match(tkNumber):
    result = Literal(kind: litNumber, floatVal: p.previous().floatVal)

  if p.match(tkString):
    result = Literal(kind: litString, strVal: p.previous().strVal)

  if p.match(tkLeftParen):
    let expr = p.expression()
    discard p.consume(tkRightParen, "Expected ')' after expression")
    result = Grouping(expression: expr)

proc unary(p: var Parser): Expression =
  if p.match(tkBang, tkMinus):
    let
      operator: Token = p.previous()
      right: Expression = p.unary()
    return Unary(operator: operator, right: right)
  return p.primary()

proc synchronize(p: var Parser) {.discardable.} =
  p.advance()
  while not p.isAtEnd():
    if p.previous().kind == tkSemicolon: return
    case p.peek().kind:
      of tkClass,
         tkFun,
         tkVar,
         tkFor,
         tkIf,
         tkWhile,
         tkPrint,
         tkReturn:
        return
      else: discard
    p.advance()

proc parse*(p: var Parser): Expression =
  # Generate the syntax tree
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
