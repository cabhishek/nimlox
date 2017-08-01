import strutils, token

# instead of import
# Error: invalid declaration order; cannot attach 'accept' to method defined here: expression.nim(25,7)
include expression

type
  AstPrinter* = ref object of Visitor

# Forward declare procs
proc visitLiteralExpression(v: Visitor, expr: Literal): string
proc visitBinaryExpression(v: Visitor, expr: Binary): string
proc visitGroupingExpression(v: Visitor, expr: Grouping): string
proc visitUnaryExpression(v: Visitor, expr: Unary): string

proc parenthesize(v: Visitor, name: string, exprs: varargs[Expression]): string =
  result = ""
  result.add("(")
  result.add(name)
  for expr in items(exprs):
    result.add(" ")
    result.add(accept[string](expr, v))
  result.add(")")

proc visitLiteralExpression(v: Visitor, expr: Literal): string =
  if expr.value.isNilOrEmpty: return "nil"
  return expr.value

proc visitBinaryExpression(v: Visitor, expr: Binary): string =
  return v.parenthesize(expr.operator.lexeme, expr.left, expr.right)

proc visitGroupingExpression(v: Visitor, expr: Grouping): string =
  return v.parenthesize("group", expr.expression)

proc visitUnaryExpression(v: Visitor, expr: Unary): string =
  return v.parenthesize(expr.operator.lexeme, expr.right)

proc print*(v: Visitor, expr: Expression): string =
  return accept[string](expr, v)
