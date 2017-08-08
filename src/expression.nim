import token, literalKind

type
  Visitor* = ref object of RootObj

  Expression* = ref object of RootObj

  Binary* = ref object of Expression
    left*: Expression
    operator*: Token
    right*: Expression

  Grouping* = ref object of Expression
    expression*: Expression

  Literal* = ref object of Expression
    case kind*: LiteralKind
      of STRING: sValue*: string
      of NUMBER: fValue*: float
      of BOOLEAN: bValue*: bool
      of NIL: value*: string
      else: discard

  Unary* = ref object of Expression
    operator*: Token
    right*: Expression

method accept*[T](expr: Expression, v: Visitor): T = quit("Overide me")

method accept*[T](expr: Binary, v: Visitor): T = return v.visitBinaryExpression(expr)

method accept*[T](expr: Grouping, v: Visitor): T = return v.visitGroupingExpression(expr)

method accept*[T](expr: Literal, v: Visitor): T = return v.visitLiteralExpression(expr)

method accept*[T](expr: Unary, v: Visitor): T = return v.visitUnaryExpression(expr)

