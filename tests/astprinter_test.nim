import unittest, expression, astprinter, token, tokenKind, literalKind

suite "test astprinter":

  test "simple binary expression":
    let expression = Binary(
      left: Literal(kind: litNumber, floatVal: 1),
      operator: Token(kind: tkPlus, lexeme: "+"),
      right: Literal(kind: litNumber, floatVal: 2)
    )
    let printer = AstPrinter()
    check:
      printer.print(expression) == "(+ 1.0 2.0)"

  test "complex binary expression":
    let expression = Binary(
      left: Unary(
        operator: Token(kind: tkMinus, lexeme: "-"),
        right: Literal(kind: litNumber, floatVal: 123)
      ),
      operator: Token(kind: tkStar, lexeme: "*"),
      right: Grouping(
        expression: Literal(kind: litNumber, floatVal: 45.67)
      )
    )
    let printer = AstPrinter()
    check:
      printer.print(expression) == "(* (- 123.0) (group 45.67))"

  test "null literal expression":
    let expression = Literal(kind: litNil)
    let printer = AstPrinter()
    check:
      printer.print(expression) == "nil"

  test "unary expression":
    let expression = Unary(
      operator: Token(kind: tkBang, lexeme: "!"),
      right: Literal(kind: litBool, boolVal: false)
    )
    let printer = AstPrinter()
    check:
      printer.print(expression) == "(! false)"
