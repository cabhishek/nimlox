import unittest, token, tokenKind, literalKind, parser, astprinter, expression, loxerror

suite "test parser":
  test "binary expression":
    let
      tokens = @[
        Token(kind: tkNumber, floatVal: 1),
        Token(kind: tkPlus, lexeme: "+"),
        Token(kind: tkNumber, floatVal: 2),
        Token(kind: tkEof)
      ]
      printer = AstPrinter()

    var p = newParser(tokens)
    let expression = p.parse()

    check:
      printer.print(expression) == "(+ 1.0 2.0)"

  test "unary expression":
    let
      tokens = @[
        Token(kind: tkBang, lexeme: "!"),
        Token(kind: tkFalse, lexeme: "false"),
        Token(kind: tkEof)
      ]
      printer = AstPrinter()

    var p = newParser(tokens)
    let expression = p.parse()

    check:
      printer.print(expression) == "(! false)"

  test "grouping expression":
    let
      tokens = @[
        Token(kind: tkMinus, lexeme: "-"),
        Token(kind: tkNumber, floatVal: 123),
        Token(kind: tkStar, lexeme: "*"),
        Token(kind: tkLeftParen, lexeme: "("),
        Token(kind: tkNumber, floatVal: 15.70),
        Token(kind: tkStar, lexeme: "+"),
        Token(kind: tkNumber, floatVal: 45.67),
        Token(kind: tkRightParen, lexeme: ")"),
        Token(kind: tkEof)
      ]
      printer = AstPrinter()

    var p = newParser(tokens)
    let expression = p.parse()

    check:
      printer.print(expression) == "(* (- 123.0) (group (+ 15.7 45.67)))"

  test "nil expression":
    let
      tokens = @[
        Token(kind: tkIdentifier, lexeme: "a"),
        Token(kind: tkEof)
      ]
      printer = AstPrinter()
    var p = newParser(tokens)
    let expr = p.parse()
    check:
      expr.hasError
