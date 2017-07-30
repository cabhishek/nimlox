import unittest, scanner, token

suite "test scanner":

  test "scan string":
    var s = newScanner("\"abc\"")
    let tokens = s.scanTokens()
    check:
      tokens[0].tokenType == TokenType.STRING
      tokens[0].strValue == "abc"

  test "scan number":
    var s = newScanner("123.456")
    let tokens = s.scanTokens()
    check:
      tokens[0].tokenType == TokenType.NUMBER
      tokens[0].lexeme == "123.456"
      tokens[0].floatValue == 123.456

  test "scan plus operator":
    var s = newScanner("2+2")
    let tokens = s.scanTokens()
    check:
      tokens.len == 4 # including EOF
      tokens[0].tokenType == TokenType.NUMBER
      tokens[0].floatValue == 2
      tokens[1].tokenType == TokenType.PLUS
      tokens[1].lexeme == "+"
      tokens[2].tokenType == TokenType.NUMBER
      tokens[2].floatValue == 2
