import strutils, expression, token, literalKind

type
  AstPrinter* = ref object of RootObj

proc strValue(expr: Literal): string =
  # Stringify literal value
  case expr.kind:
    of LiteralKind.STRING: result = expr.sValue
    of LiteralKind.NUMBER: result = $expr.fValue
    of LiteralKind.BOOLEAN: result = $expr.bValue
    of LiteralKind.NIL: result = "nil"

method print*(p: AstPrinter, expr: Expression): string {.base.}=
  # override for concrete Expression types
  return ""

# generic method to retain concrete expression type info within polymorphic context
method print*[T: Binary|Unary|Grouping|Literal](p: AstPrinter, expr: T): string =
    # dynamic dispatch on correct expression types
    return p.print(expr)

template parenthesize(p: AstPrinter, name: string, exprs: varargs[Expression]): string =
  # retain expression type object info within methods
  var res = ""
  res.add("(")
  res.add(name)
  for expr in items(exprs):
    res.add(" ")
    res.add(p.print(expr)) # recurse
  res.add(")")
  res # will be returned from calling methods

method print(p: AstPrinter, expr: Binary): string =
  return parenthesize(p,
    expr.operator.lexeme,
    expr.left,
    expr.right
  )

method print(p: AstPrinter, expr: Literal): string =
  return expr.strValue

method print(p: AstPrinter, expr: Grouping): string =
  return parenthesize(p, "group", expr.expression)

method print(p: AstPrinter, expr: Unary): string =
  return parenthesize(p,
    expr.operator.lexeme,
    expr.right
  )
