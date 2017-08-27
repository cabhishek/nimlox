import unittest, lexer, token, tokenKind

suite "test lexer":

  test "scan string":
    var lex = newLexer("\"abc\"")
    let tokens = lex.scanTokens()
    check:
      tokens[0].kind == tkString
      tokens[0].strVal == "abc"

  test "scan number":
    var lex = newLexer("123.456")
    let tokens = lex.scanTokens()
    check:
      tokens[0].kind == tkNumber
      tokens[0].lexeme == "123.456"
      tokens[0].floatVal == 123.456

  test "scan plus operator":
    var lex = newLexer("2+2")
    let tokens = lex.scanTokens()
    check:
      tokens.len == 4 # including EOF
      tokens[0].kind == tkNumber
      tokens[0].floatVal == 2
      tokens[1].kind == tkPlus
      tokens[1].lexeme == "+"
      tokens[2].kind == tkNumber
      tokens[2].floatVal == 2
