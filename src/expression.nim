import token

type
  Visitor* = ref object of RootObj

  Expression* = ref object of RootObj

  Literal* = ref object of Expression
    value*: string

  Grouping* = ref object of Expression
    expression*: Expression

  Binary* = ref object of Expression
    left*: Expression
    operator*: Token
    right*: Expression

  Unary* = ref object of Expression
    operator*: Token
    right*: Expression

method accept*[T](expr: Expression, v: Visitor): T = quit("Overide me")

method accept*[T](expr: Literal, v: Visitor): T = return v.visitLiteralExpression(expr)

method accept*[T](expr: Grouping, v: Visitor): T = return v.visitGroupingExpression(expr)

method accept*[T](expr: Binary, v: Visitor): T = return v.visitBinaryExpression(expr)

method accept*[T](expr: Unary, v: Visitor): T = return v.visitUnaryExpression(expr)

