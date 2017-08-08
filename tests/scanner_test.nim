import unittest, scanner, token, tokenKind

suite "test scanner":

  test "scan string":
    var s = newScanner("\"abc\"")
    let tokens = s.scanTokens()
    check:
      tokens[0].kind == TokenKind.STRING
      tokens[0].sValue == "abc"

  test "scan number":
    var s = newScanner("123.456")
    let tokens = s.scanTokens()
    check:
      tokens[0].kind == TokenKind.NUMBER
      tokens[0].lexeme == "123.456"
      tokens[0].fValue == 123.456

  test "scan plus operator":
    var s = newScanner("2+2")
    let tokens = s.scanTokens()
    check:
      tokens.len == 4 # including EOF
      tokens[0].kind == TokenKind.NUMBER
      tokens[0].fValue == 2
      tokens[1].kind == TokenKind.PLUS
      tokens[1].lexeme == "+"
      tokens[2].kind == TokenKind.NUMBER
      tokens[2].fValue == 2
