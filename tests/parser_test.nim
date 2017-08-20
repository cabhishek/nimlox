import unittest, token, tokenKind, literalKind, parser, astprinter, expression

suite "test parser":
  test "binary expression":
    let
      tokens = @[
        Token(
          kind: Tokenkind.NUMBER,
          fValue: 1
        ),
        Token(
          kind: Tokenkind.PLUS,
          lexeme: "+"
        ),
        Token(
          kind: Tokenkind.NUMBER,
          fValue: 2
        ),
        Token(kind: Tokenkind.EOF)
      ]
      printer = AstPrinter()

    var p = newParser(tokens)
    let expression = p.parse()

    check:
      printer.print(expression) == "(+ 1.0 2.0)"

  test "unary expression":
    let
      tokens = @[
        Token(
          kind: Tokenkind.BANG,
          lexeme: "!"
        ),
        Token(
          kind: Tokenkind.FALSE,
          lexeme: "false"
        ),
        Token(kind: Tokenkind.EOF)
      ]
      printer = AstPrinter()

    var p = newParser(tokens)
    let expression = p.parse()

    check:
      printer.print(expression) == "(! false)"

  test "grouping expression":
    let
      tokens = @[
        Token(kind: TokenKind.MINUS, lexeme: "-"),
        Token(kind: TokenKind.NUMBER, fValue: 123),
        Token(kind: TokenKind.STAR, lexeme: "*"),
        Token(kind: TokenKind.LEFT_PAREN, lexeme: "("),
        Token(kind: TokenKind.NUMBER, fValue: 45.67),
        Token(kind: TokenKind.RIGHT_PAREN, lexeme: ")"),
        Token(kind: Tokenkind.EOF)
      ]
      printer = AstPrinter()

    var p = newParser(tokens)
    let expression = p.parse()

    check:
      printer.print(expression) == "(* (- 123.0) (group 45.67))"
