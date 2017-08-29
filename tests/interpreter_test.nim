import unittest, interpreter, expression, token, tokenKind, literalKind

suite "test interpreter":

  test "simple unary expression":
    let
      expr = Unary(
        operator: Token(kind: tkMinus, lexeme: "-"),
        right: Literal(kind: litNumber, floatVal: 123.0)
      )
      i = Interpreter()
      result = i.evaluate(expr)
    check:
       result.floatVal == -123.0

  test "bool unary expression":
    let
      expr = Unary(
        operator: Token(kind: tkBang, lexeme: "!"),
        right: Literal(kind: litBool, boolVal: false)
      )
      i = Interpreter()
      result = i.evaluate(expr)
    check:
       result.boolVal == true

  test "addition binary expression":
    let
      expr = Binary(
        left: Literal(kind: litNumber, floatVal: 2),
        operator: Token(kind: tkPlus, lexeme: "+"),
        right: Literal(kind: litNumber, floatVal: 3)
      )
      i = Interpreter()
      result = i.evaluate(expr)
    check:
       result.floatVal == 5.0

  test "multiplication binary expression":
    let
      expr = Binary(
        left: Literal(kind: litNumber, floatVal: 2),
        operator: Token(kind: tkStar, lexeme: "*"),
        right: Literal(kind: litNumber, floatVal: 3)
      )
      i = Interpreter()
      result = i.evaluate(expr)
    check:
       result.floatVal == 6.0

  test "subtraction binary expression":
    let
      expr = Binary(
        left: Literal(kind: litNumber, floatVal: 2),
        operator: Token(kind: tkMinus, lexeme: "-"),
        right: Literal(kind: litNumber, floatVal: 3)
      )
      i = Interpreter()
      result = i.evaluate(expr)
    check:
       result.floatVal == -1.0

  test "concat binary expression":
    let
      expr = Binary(
        left: Literal(kind: litString, strVal: "a"),
        operator: Token(kind: tkPlus, lexeme: "+"),
        right: Literal(kind: litString, strVal: "b")
      )
      i = Interpreter()
      result = i.evaluate(expr)
    check:
       result.strVal == "ab"
