import token

type
  Visitor* = ref object of RootObj

  Expression* = ref object of RootObj

  Literal* = ref object of Expression
    value*: string

  Grouping* = ref object of Expression
    expr*: Expression

  Binary* = ref object of Expression
    left*: Expression
    operator*: Token
    right*: Expression

  Unary* = ref object of Expression
    operator*: Token
    right*: Expression

proc accept*[T](expr: Literal, v: Visitor): T = return v.visitLiteralExpression(expr)

proc accept*[T](expr: Grouping, v: Visitor): T = return v.visitGroupingExpression(expr)

proc accept*[T](expr: Binary, v: Visitor): T = return v.visitBinaryExpression(expr)

proc accept*[T](expr: Unary, v: Visitor): T = return v.visitUnaryExpression(expr)

