import os, strutils, token, tokenKind, loxerror, utils, tables

type
  # Lexer represents a lexical Lexer that does lexical-analysis on the source.
  # It holds the basic metadata like the input to Lexer and in-process state.
  Lexer* = object
    source*: string
    tokens*: seq[Token]
    start*, current*, line*: int
const
  keywords = {
     "and"    : tkAnd,
     "class"  : tkClass,
     "else"   : tkElse,
     "false"  : tkFalse,
     "fun"    : tkFun,
     "if"     : tkIf,
     "nil"    : tkNil,
     "or"     : tkOr,
     "print"  : tkPrint,
     "return" : tkReturn,
     "super"  : tkSuper,
     "this"   : tkThis,
     "true"   : tkTrue,
     "var"    : tkVar,
     "while"  : tkWhile,
  }.toTable

proc isAtEnd(lex: Lexer): bool =
  # Check if EOF reached
  return lex.current >= lex.source.len

proc advance(lex: var Lexer): char {.discardable.} =
  # Returns the current char and moves to the next one
  lex.current += 1
  return lex.source[lex.current-1]

proc peek(lex: var Lexer): char =
  # Returns the current char without moving to the next one
  if lex.isAtEnd():
    result = '\0'
  else:
    result = lex.source[lex.current]

proc peekNext(lex: var Lexer): char =
  # Returns the current + 1 char without moving to the next one
  if lex.current + 1 >= lex.source.len:
    result = '\0'
  else:
    result = lex.source[lex.current+1]

proc match(lex: var Lexer, expected: char): bool =
  result = true
  if lex.isAtEnd():
    result = false
  elif lex.source[lex.current] != expected:
    result = false
  else:
    # Match found and increment position.
    # Group current & previous chars into a single tokenKind
    lex.current += 1

template addToken(lex: var Lexer, tokKind: TokenKind) =
  # Add token along with metadata
  lex.tokens.add(
    Token(
      line: lex.line,
      kind: tokKind,
      lexeme: lex.source[lex.start..lex.current-1]
    )
  )

template addStringToken(lex: var Lexer, literal: string) =
  # Add string token along with metadata
  lex.tokens.add(
    Token(
      line: lex.line,
      kind: tkString,
      lexeme: lex.source[lex.start..lex.current-1],
      strVal: literal
    )
  )

template addFloatToken(lex: var Lexer, literal: float) =
  # Add float token along with metadata
  lex.tokens.add(
    Token(
      line: lex.line,
      kind: tkNumber,
      lexeme: lex.source[lex.start..lex.current-1],
      floatVal: literal
    )
  )

proc scanNumber(lex: var Lexer) =
  while isDigit(lex.peek()): lex.advance()
  if lex.peek() == '.' and isDigit(lex.peekNext()):
    lex.advance()
    while isDigit(lex.peek()): lex.advance()
  let value = lex.source[lex.start..lex.current-1]
  lex.addFloatToken(parseFloat(value))

proc scanString(lex: var Lexer) =
  while lex.peek() != '\"' and not lex.isAtEnd():
    if lex.peek() == '\L': lex.line += 1
    lex.advance()

  if lex.isAtEnd():
    reportError(lex.line, lex.source[lex.start..lex.current], "Unterminated string")

  lex.advance()
  # Trim the surrounding quotelex.
  let value = lex.source[lex.start+1..lex.current-2]
  lex.addStringToken(value)

proc identifier(lex: var Lexer) =
  while isAlphaNumeric(lex. peek()): lex.advance()
  let
    text = lex.source[lex.start..lex.current-1]
    tokenKind = if keywords.contains(text): keywords[text]
                else: tkIdentifier
  lex.addToken(tokenKind)

proc scanToken(lex: var Lexer) =
  # Infers the type of lexical token from its string representation
  let c: char = lex.advance()
  case c:
    of '(':
       lex.addToken(tkLeftParen)
    of ')':
       lex.addToken(tkRightParen)
    of '{':
       lex.addToken(tkLeftBrace)
    of '}':
       lex.addToken(tkRightBrace)
    of ',':
       lex.addToken(tkComma)
    of '.':
       lex.addToken(tkDot)
    of '-':
       lex.addToken(tkMinus)
    of '+':
       lex.addToken(tkPlus)
    of ';':
       lex.addToken(tkSemicolon)
    of '*':
       lex.addToken(tkStar)
    of '\r', '\t', ' ': # Ignore whitespace
      discard
    of '\L': # New line char '\n'
      lex.line += 1
    of '!':
       lex.addToken(if lex.match('='): tkBangEqual else: tkBang)
    of '=':
       lex.addToken(if lex.match('='): tkEqualEqual else: tkEqual)
    of '>':
       lex.addToken(if lex.match('='): tkGreaterEqual else: tkGreater)
    of '<':
       lex.addToken(if lex.match('='): tkLessEqual else: tkLess)
    of '/':
      if lex.match('/'):
        while(lex.peek() != '\L' and not lex.isAtEnd()):
          lex.advance()
      else: lex.addToken(tkSlash)
    of '\"': lex.scanString()
    else:
      if isDigit(c): lex.scanNumber()
      elif utils.isAlpha(c): lex.identifier()
      else:
        reportError(lex.line, lex.source[lex.start..lex.current], "Unrecognized letter $1" % $c)

proc scanTokens*(lex: var Lexer): seq[Token] =
  # ScanTokens keeps scanning the source code untils it find the EOF delimiter.
  # It returns a seq of tokens that represents the entire source code.
  while not lex.isAtEnd():
    lex.start = lex.current
    lex.scanToken()
  # EOF token
  lex.tokens.add(
    Token(
      line: lex.line,
      kind: tkEof,
      lexeme: ""
    )
  )
  return lex.tokens

proc newLexer*(source: string): Lexer =
  # Create a new Lexer instance
  return Lexer(
    source: source,
    tokens: @[],
    start: 0,
    current: 0,
    line:1
  )
