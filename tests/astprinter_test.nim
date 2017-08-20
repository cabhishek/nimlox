import unittest, expression, astprinter, token, tokenKind, literalKind

suite "test astprinter":

  test "simple binary expression":
    let expression = Binary(
      left: Literal(kind: LiteralKind.NUMBER, fValue: 1),
      operator: Token(kind: TokenKind.PLUS, lexeme: "+"),
      right: Literal(kind: LiteralKind.NUMBER, fValue: 2)
    )
    let printer = AstPrinter()
    check:
      printer.print(expression) == "(+ 1.0 2.0)"

  test "complex binary expression":
    let expression = Binary(
      left: Unary(
        operator: Token(kind: TokenKind.MINUS, lexeme: "-"),
        right: Literal(kind: LiteralKind.NUMBER, fValue: 123)
      ),
      operator: Token(kind: TokenKind.STAR, lexeme: "*"),
      right: Grouping(
        expression: Literal(kind: LiteralKind.NUMBER, fValue: 45.67)
      )
    )
    let printer = AstPrinter()
    check:
      printer.print(expression) == "(* (- 123.0) (group 45.67))"

  test "null literal expression":
    let expression = Literal(kind: LiteralKind.NIL, value: nil)
    let printer = AstPrinter()
    check:
      printer.print(expression) == "nil"

  test "unary expression":
    let expression = Unary(
      operator: Token(kind: Tokenkind.BANG, lexeme: "!"),
      right: Literal(kind: LiteralKind.BOOLEAN, bValue: false)
    )
    let printer = AstPrinter()
    check:
      printer.print(expression) == "(! false)"
