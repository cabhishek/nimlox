import unittest, expression, token, tokenKind, literalKind

suite "test expression":

  test "literal expression types":
    let sLit = Literal(kind: LiteralKind.STRING, sValue: "abc")
    let fLit = Literal(kind: LiteralKind.NUMBER, fValue: 123.4)
    let bLit = Literal(kind: LiteralKind.BOOLEAN, bValue: true)
    let nilLit = Literal(kind: LiteralKind.NIL, value: nil)
    check:
      sLit.sValue is string
      bLit.bValue is bool
      fLit.fValue is float
      nilLit.value.isNil
