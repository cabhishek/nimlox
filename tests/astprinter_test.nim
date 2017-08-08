import unittest, astprinter, token, tokenKind, literalKind

suite "test astprinter":

  test "simple binary expression":
    let expression = Binary(
      left: Literal(kind: LiteralKind.NUMBER, fValue: 1.0),
      operator: Token(kind: TokenKind.PLUS, lexeme: "+", line: 1),
      right: Literal(kind: LiteralKind.NUMBER, fValue: 2.0)
    )
    let printer = AstPrinter()
    check:
      printer.print(expression) == "(+ 1.0 2.0)"

  test "complex binary expression":
    let expression = Binary(
      left: Unary(
        operator: Token(kind: TokenKind.MINUS, lexeme: "-", line: 1),
        right: Literal(kind: LiteralKind.NUMBER, fValue: 123.0)
      ),
      operator: Token(kind: TokenKind.STAR, lexeme: "*", line: 1),
      right: Grouping(
        expression: Literal(kind: LiteralKind.NUMBER, fValue: 45.67)
      )
    )
    let printer = AstPrinter()
    check:
      printer.print(expression) == "(* (- 123.0) (group 45.67))"
