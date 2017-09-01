import unittest, interpreter, expression, token, tokenKind, literalKind

suite "test interpreter":

  test "simple unary expression":
    let
      expr = Unary(
        operator: Token(kind: tkMinus, lexeme: "-"),
        right: Literal(kind: litNumber, floatVal: 123.0)
      )
      i = Interpreter()
      result = i.interpret(expr)
    check:
       result.floatVal == -123.0

  test "bool unary expression":
    let
      expr = Unary(
        operator: Token(kind: tkBang, lexeme: "!"),
        right: Literal(kind: litBool, boolVal: false)
      )
      i = Interpreter()
      result = i.interpret(expr)
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
      result = i.interpret(expr)
    check:
       result.floatVal == 5.0

  test "float to int conversion for display":
    let
      expr = Binary(
        left: Literal(kind: litNumber, floatVal: 2),
        operator: Token(kind: tkPlus, lexeme: "+"),
        right: Literal(kind: litNumber, floatVal: 3)
      )
      i = Interpreter()
      result = i.interpret(expr)
    check:
       $result == "5" # stripped .0

  test "multiplication binary expression":
    let
      expr = Binary(
        left: Literal(kind: litNumber, floatVal: 2),
        operator: Token(kind: tkStar, lexeme: "*"),
        right: Literal(kind: litNumber, floatVal: 3)
      )
      i = Interpreter()
      result = i.interpret(expr)
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
      result = i.interpret(expr)
    check:
       result.floatVal == -1.0

  test "equality binary expression":
    let
      expr = Binary(
        left: Literal(kind: litNumber, floatVal: 2),
        operator: Token(kind: tkEqualEqual, lexeme: "=="),
        right: Literal(kind: litNumber, floatVal: 2)
      )
      i = Interpreter()
      result = i.interpret(expr)
    check:
       result.boolVal == true

  test "not equality binary expression":
    let
      expr = Binary(
        left: Literal(kind: litNumber, floatVal: 3),
        operator: Token(kind: tkBangEqual, lexeme: "!="),
        right: Literal(kind: litNumber, floatVal: 2)
      )
      i = Interpreter()
      result = i.interpret(expr)
    check:
       result.boolVal == true

  test "greater than binary expression":
    let
      expr = Binary(
        left: Literal(kind: litNumber, floatVal: 3),
        operator: Token(kind: tkGreater, lexeme: ">"),
        right: Literal(kind: litNumber, floatVal: 2)
      )
      i = Interpreter()
      result = i.interpret(expr)
    check:
       result.boolVal == true

  test "greater than equal binary expression":
    let
      expr = Binary(
        left: Literal(kind: litNumber, floatVal: 3),
        operator: Token(kind: tkGreaterEqual, lexeme: ">="),
        right: Literal(kind: litNumber, floatVal: 4)
      )
      i = Interpreter()
      result = i.interpret(expr)
    check:
      result.boolVal == false

  test "less than binary expression":
    let
      expr = Binary(
        left: Literal(kind: litNumber, floatVal: 3),
        operator: Token(kind: tkLess, lexeme: "<"),
        right: Literal(kind: litNumber, floatVal: 2)
      )
      i = Interpreter()
      result = i.interpret(expr)
    check:
       result.boolVal == false

  test "less than equal binary expression":
    let
      expr = Binary(
        left: Literal(kind: litNumber, floatVal: 2),
        operator: Token(kind: tkLessEqual, lexeme: "<="),
        right: Literal(kind: litNumber, floatVal: 2)
      )
      i = Interpreter()
      result = i.interpret(expr)
    check:
       result.boolVal == true

  test "concat binary expression":
    let
      expr = Binary(
        left: Literal(kind: litString, strVal: "a"),
        operator: Token(kind: tkPlus, lexeme: "+"),
        right: Binary(
          left: Literal(kind: litString, strVal: "b"),
          operator: Token(kind: tkPlus, lexeme: "+"),
          right: Literal(kind: litString, strVal: "c")
        )
      )
      i = Interpreter()
      result = i.interpret(expr)
    check:
       result.strVal == "abc"

  test "complex binary expression":
    let
      expr = Binary(
        left: Literal(kind: litNumber, floatVal: 3),
        operator: Token(kind: tkPlus, lexeme: "+"),
        right: Binary(
          left: Literal(kind: litNumber, floatVal: 2),
          operator: Token(kind: tkMinus, lexeme: "-"),
          right: Binary(
            left: Literal(kind: litNumber, floatVal: 2),
            operator: Token(kind: tkMinus, lexeme: "-"),
            right: Literal(kind: litNumber, floatVal: 3)
          )
        )
      )
      i = Interpreter()
      result = i.interpret(expr)
    check:
       result.floatVal == 6

  test "grouping expression":
    let
      expr = Grouping(
        expression: Binary(
          left: Literal(kind: litNumber, floatVal: 10),
          operator: Token(kind: tkStar, lexeme:"*"),
          right: Binary(
            left: Literal(kind: litNumber, floatVal: 1),
            operator: Token(kind: tkPlus, lexeme: "+"),
            right: Literal(kind: litNumber, floatVal: 2)
          )
        )
      )
      i = Interpreter()
      result = i.interpret(expr)
    check:
      result.floatVal == 30

  test "invalid operand error":
    let
      expr = Binary(
        left: Literal(kind: litNumber, floatVal: 1),
        operator: Token(kind: tkPlus, lexeme: "+"),
        right: Literal(kind: litString, strVal: "a")
      )
      i = Interpreter()
      result = i.interpret(expr)
    check:
       result.kind == loxException
