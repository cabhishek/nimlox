import os, strutils, token, tokenKind, errors, utils, tables

type
  # Scanner represents a lexical scanner that does lexical-analysis on the source.
  # It holds the basic metadata like the input to scanner and in-process state.
  Scanner* = object
    source*: string
    tokens*: seq[Token]
    start*, current*, line*: int

const
  keywords = {
    "and"    : TokenKind.AND,
    "class"  : TokenKind.CLASS,
    "else"   : TokenKind.ELSE,
    "false"  : TokenKind.FALSE,
    "fun"    : TokenKind.FUN,
    "if"     : TokenKind.IF,
    "nil"    : TokenKind.NIL,
    "or"     : TokenKind.OR,
    "print"  : TokenKind.PRINT,
    "return" : TokenKind.RETURN,
    "super"  : TokenKind.SUPER,
    "this"   : TokenKind.THIS,
    "true"   : TokenKind.TRUE,
    "var"    : TokenKind.VAR,
    "while"  : TokenKind.WHILE,
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
    # Group current & previous chars into a single tokenKind
    s.current += 1

# Overloaded methods
proc addToken(s: var Scanner, kind: TokenKind) =
  # Add token along with metadata
  s.tokens.add(
    Token(
      line: s.line,
      kind: kind,
      lexeme: s.source[s.start..s.current-1]
    )
  )

proc addStringToken(s: var Scanner, literal: string) =
  # Add string token along with metadata
  s.tokens.add(
    Token(
      line: s.line,
      kind: TokenKind.STRING,
      lexeme: s.source[s.start..s.current-1],
      sValue: literal
    )
  )

proc addFloatToken(s: var Scanner, literal: float) =
  # Add float token along with metadata
  s.tokens.add(
    Token(
      line: s.line,
      kind: TokenKind.NUMBER,
      lexeme: s.source[s.start..s.current-1],
      fValue: literal
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
    tokenKind = if keywords.contains(text): keywords[text]
                else: TokenKind.IDENTIFIER
  s.addToken(tokenKind)

proc scanToken(s: var Scanner) =
  # Infers the type of lexical token from its string representation
  let c: char = s.advance()
  case c:
    of '(':
      s.addToken(TokenKind.LEFT_PAREN)
    of ')':
      s.addToken(TokenKind.RIGHT_PAREN)
    of '{':
      s.addToken(TokenKind.LEFT_BRACE)
    of '}':
      s.addToken(TokenKind.RIGHT_BRACE)
    of ',':
      s.addToken(TokenKind.COMMA)
    of '.':
      s.addToken(TokenKind.DOT)
    of '-':
      s.addToken(TokenKind.MINUS)
    of '+':
      s.addToken(TokenKind.PLUS)
    of ';':
      s.addToken(TokenKind.SEMICOLON)
    of '*':
      s.addToken(TokenKind.STAR)
    of '\r', '\t', ' ': # Ignore whitespace
      discard
    of '\L': # New line char '\n'
      s.line += 1
    of '!':
      s.addToken(if s.match('='): TokenKind.BANG_EQUAL else: TokenKind.BANG)
    of '=':
      s.addToken(if s.match('='): TokenKind.EQUAL_EQUAL else: TokenKind.EQUAL)
    of '>':
      s.addToken(if s.match('='): TokenKind.GREATER_EQUAL else: TokenKind.GREATER)
    of '<':
      s.addToken(if s.match('='): TokenKind.LESS_EQUAL else: TokenKind.LESS)
    of '/':
      if s.match('/'):
        while(s.peek() != '\L' and not s.isAtEnd()):
          s.advance()
      else: s.addToken(TokenKind.SLASH)
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
      kind: TokenKind.EOF,
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
