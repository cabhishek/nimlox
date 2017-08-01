import strutils, token, expression

type
  AstPrinter = ref object of Visitor

# Forward declare procs
proc visitLiteralExpression(v: Visitor, expr: Literal): string
proc visitGroupingExpression(v: Visitor, expr: Grouping): string
proc visitBinaryExpression(v: Visitor, expr: Binary): string
proc visitUnaryExpression(v: Visitor, expr: Unary): string

proc parenthesize(v: Visitor, name: string, expr: Expression): string =
  return "foo"
  #return expr.accept(v)
  #return accept[string](expr, AstPrinter())

proc visitLiteralExpression(v: Visitor, expr: Literal): string =
  if expr.value.isNilOrEmpty: return "nil"
  return expr.value

proc visitGroupingExpression(v: Visitor, expr: Grouping): string =
  return v.parenthesize("group", expr.expression)

proc visitBinaryExpression(v: Visitor, expr: Binary): string =
  return v.parenthesize(expr.operator.lexeme, expr.left)

proc visitUnaryExpression(v: Visitor, expr: Unary): string =
  return v.parenthesize(expr.operator.lexeme, expr.right)

proc print(v: Visitor, expr: Expression): string =
  return accept[string](expr, AstPrinter())

when isMainModule:
  let expr = Binary(
    left: Unary(
      operator: Token(tokenType: TokenType.MINUS, lexeme: "-", line: 1),
      right: Literal(value: "123")
    ),
    operator: Token(tokenType: TokenType.STAR, lexeme: "*", line: 1),
    right: Grouping(expression: Literal(value: "45.67"))
  )
