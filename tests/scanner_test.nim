import unittest, scanner, token

suite "test scanner":

  test "scan string":
    var s = newScanner("\"abc\"")
    let tokens = s.scanTokens()
    check:
      tokens[0].tokenType == TokenType.STRING
      tokens[0].literal == "abc"

  test "scan number":
    var s = newScanner("123.456")
    let tokens = s.scanTokens()
    check:
      tokens[0].tokenType == TokenType.NUMBER
      tokens[0].literal == "123.456"
