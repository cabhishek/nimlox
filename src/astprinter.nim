import strutils, expression, token, literalKind

type
  AstPrinter* = ref object of RootObj

proc `$`(expr: Literal): string =
  # Stringify literal value
  case expr.kind:
    of litString: result = expr.strVal
    of litNumber: result = $expr.floatVal
    of litBool: result = $expr.boolVal
    of litNil: result = "nil"

method print*(self: AstPrinter, expr: Expression): string {.base.}=
  # override from concrete Expression types
  discard

# generic method to retain concrete expression type info within polymorphic context
method print*[T: Binary|Unary|Grouping|Literal](self:AstPrinter, expr: T): string =
    # dynamic dispatch on correct expression types
    return self.print(expr)

template parenthesize(self: AstPrinter, name: string, exprs: varargs[Expression]): string =
  # retain expression object info within methods
  result=""
  result.add("(")
  result.add(name)
  for expr in items(exprs):
    result.add(" ")
    result.add(self.print(expr)) # recurse
  result.add(")")
  result # will be returned from the calling methods

method print(self: AstPrinter, expr: Binary): string =
  return parenthesize(self,
    expr.operator.lexeme,
    expr.left,
    expr.right
  )

method print(self: AstPrinter, expr: Literal): string =
  # stringify literal value
  return $expr

method print(self: AstPrinter, expr: Grouping): string =
  return parenthesize(self, "group", expr.expression)

method print(self: AstPrinter, expr: Unary): string =
  return parenthesize(self,
    expr.operator.lexeme,
    expr.right
  )
