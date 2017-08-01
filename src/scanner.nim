import os, strutils, token, tokenType, errors, utils, tables

type
  # Scanner represents a lexical scanner that does lexical-analysis on the source.
  # It holds the basic metadata like the input to scanner and in-process state.
  Scanner* = object
    source*: string
    tokens*: seq[Token]
    start*, current*, line*: int

const
  keywords = {
    "and"    : TokenType.AND,
    "class"  : TokenType.CLASS,
    "else"   : TokenType.ELSE,
    "false"  : TokenType.FALSE,
    "fun"    : TokenType.FUN,
    "if"     : TokenType.IF,
    "nil"    : TokenType.NIL,
    "or"     : TokenType.OR,
    "print"  : TokenType.PRINT,
    "return" : TokenType.RETURN,
    "super"  : TokenType.SUPER,
    "this"   : TokenType.THIS,
    "true"   : TokenType.TRUE,
    "var"    : TokenType.VAR,
    "while"  : TokenType.WHILE,
  }.toTable

proc isAtEnd(s: Scanner): bool =
  # Check if EOF reached
  return s.current >= s.source.len

proc advance(s: var Scanner): char {.discardable.} =
  # Returns the current char and moves to the next one
  s.current += 1
  return s.source[s.current-1]

proc peek(s: var Scanner): char =
  # Returns the current char without moving to the next one
  if s.isAtEnd():
    result = '\0'
  else:
    result = s.source[s.current]

proc peekNext(s: var Scanner): char =
  # Returns the current + 1 char without moving to the next one
  if s.current + 1 >= s.source.len:
    result = '\0'
  else:
    result = s.source[s.current+1]

proc match(s: var Scanner, expected: char): bool =
  result = true
  if s.isAtEnd():
    result = false
  elif s.source[s.current] != expected:
    result = false
  else:
    # Match found and increment position.
    # Group current & previous chars into a single tokenType
    s.current += 1

# Overloaded methods
proc addToken(s: var Scanner, tokenType: TokenType) =
  # Add token along with metadata
  s.tokens.add(
    Token(
      line: s.line,
      tokenType: tokenType,
      lexeme: s.source[s.start..s.current-1]
    )
  )

proc addStringToken(s: var Scanner, literal: string) =
  # Add string token along with metadata
  s.tokens.add(
    Token(
      line: s.line,
      tokenType: TokenType.STRING,
      lexeme: s.source[s.start..s.current-1],
      strValue: literal
    )
  )

proc addFloatToken(s: var Scanner, literal: float) =
  # Add float token along with metadata
  s.tokens.add(
    Token(
      line: s.line,
      tokenType: TokenType.NUMBER,
      lexeme: s.source[s.start..s.current-1],
      floatValue: literal
    )
  )

proc scanNumber(s: var Scanner) =
  while isDigit(s.peek()): s.advance()

  if s.peek() == '.' and isDigit(s.peekNext()):
    s.advance()
    while isDigit(s.peek()): s.advance()

  let value = s.source[s.start..s.current-1]
  s.addFloatToken(parseFloat(value))

proc scanString(s: var Scanner) =
  while s.peek() != '\"' and not s.isAtEnd():
    if s.peek() == '\L': s.line += 1
    s.advance()

  if s.isAtEnd():
    reportError(s.line, s.source[s.start..s.current], "Unterminated string")

  s.advance()

  # Trim the surrounding quotes.
  let value = s.source[s.start+1..s.current-2]
  s.addStringToken(value)

proc identifier(s: var Scanner) =
  while isAlphaNumeric(s. peek()): s.advance()
  let
    text: string = s.source[s.start..s.current-1]
    tokenType = if keywords.contains(text): keywords[text]
                else: TokenType.IDENTIFIER
  s.addToken(tokenType)

proc scanToken(s: var Scanner) =
  # Infers the type of lexical token from its string representation
  let c: char = s.advance()
  case c:
    of '(':
      s.addToken(TokenType.LEFT_PAREN)
    of ')':
      s.addToken(TokenType.RIGHT_PAREN)
    of '{':
      s.addToken(TokenType.LEFT_BRACE)
    of '}':
      s.addToken(TokenType.RIGHT_BRACE)
    of ',':
      s.addToken(TokenType.COMMA)
    of '.':
      s.addToken(TokenType.DOT)
    of '-':
      s.addToken(TokenType.MINUS)
    of '+':
      s.addToken(TokenType.PLUS)
    of ';':
      s.addToken(TokenType.SEMICOLON)
    of '*':
      s.addToken(TokenType.STAR)
    of '\r', '\t', ' ': # Ignore whitespace
      discard
    of '\L': # New line char '\n'
      s.line += 1
    of '!':
      s.addToken(if s.match('='): TokenType.BANG_EQUAL else: TokenType.BANG)
    of '=':
      s.addToken(if s.match('='): TokenType.EQUAL_EQUAL else: TokenType.EQUAL)
    of '>':
      s.addToken(if s.match('='): TokenType.GREATER_EQUAL else: TokenType.GREATER)
    of '<':
      s.addToken(if s.match('='): TokenType.LESS_EQUAL else: TokenType.LESS)
    of '/':
      if s.match('/'):
        while(s.peek() != '\L' and not s.isAtEnd()):
          s.advance()
      else: s.addToken(TokenType.SLASH)
    of '\"': s.scanString()
    else:
      if isDigit(c): s.scanNumber()
      elif utils.isAlpha(c): s.identifier()
      else:
        reportError(s.line, s.source[s.start..s.current], "Unrecognized letter $1" % $c)

proc scanTokens*(s: var Scanner): seq[Token] =
  # ScanTokens keeps scanning the source code untils it find the EOF delimiter.
  # It returns a seq of tokens that represents the entire source code.
  while not s.isAtEnd():
    s.start = s.current
    s.scanToken()

  # EOF token
  s.tokens.add(
    Token(
      line: s.line,
      tokenType: TokenType.EOF,
      lexeme: ""
    )
  )
  return s.tokens

proc newScanner*(source: string): Scanner =
  # Create a new Scanner instance
  return Scanner(
    source: source,
    tokens: @[],
    start: 0,
    current: 0,
    line:1
  )
