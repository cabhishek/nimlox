import unittest, astprinter, token, tokenType

suite "test astprinter":

  test "simple binary expression":
    let expression = Binary(
      left: Literal(value: "1"),
      operator: Token(tokenType: TokenType.PLUS, lexeme: "+", line: 1),
      right: Literal(value: "2")
    )
    let printer = AstPrinter()
    check:
      printer.print(expression) == "(+ 1 2)"

  test "complex binary expression":
    let expression = Binary(
      left: Unary(
        operator: Token(tokenType: TokenType.MINUS, lexeme: "-", line: 1),
        right: Literal(value: "123")
      ),
      operator: Token(tokenType: TokenType.STAR, lexeme: "*", line: 1),
      right: Grouping(
        expression: Literal(value: "45.67")
      )
    )
    let printer = AstPrinter()
    check:
      printer.print(expression) == "(* (- 123) (group 45.67))"
