import unittest, expr, token, tokenKind, literalKind

suite "test expression":

  test "literal types":
    let strLit = Literal(kind: litString, strVal: "abc")
    let floatLit = Literal(kind: litNumber, floatVal: 123.4)
    let boolLit = Literal(kind: litBool, boolVal: true)
    check:
      strLit.strVal is string
      boolLit.boolVal is bool
      floatLit.floatVal is float
