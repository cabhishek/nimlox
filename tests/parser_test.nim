import unittest, token, tokenKind, literalKind, parser, astprinter

suite "test parser":
  test "binary expression":
    let
      tokens = @[
        Token(
          kind: Tokenkind.NUMBER,
          fValue: 2
        ),
        Token(
          kind: Tokenkind.PLUS,
          lexeme: "+"
        ),
        Token(
          kind: Tokenkind.NUMBER,
          fValue: 2
        ),
      ]
      printer = AstPrinter()

    let expression = Binary(
      left: Literal(kind: LiteralKind.NUMBER, fValue: 1),
      operator: Token(kind: TokenKind.PLUS, lexeme: "+"),
      right: Literal(kind: LiteralKind.NUMBER, fValue: 2)
    )
    var p = newParser(tokens)
    #let expression2 = p.parse()

    check:
      printer.print(expression) == "(+ 1.0 2.0)"


