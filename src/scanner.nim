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

proc isAtEnd(self: Scanner): bool =
  # Check if EOF reached
  return self.current >= self.source.len

proc advance(self: var Scanner): char {.discardable.} =
  # Returns the current char and moves to the next one
  self.current += 1
  return self.source[self.current-1]

proc peek(self: var Scanner): char =
  # Returns the current char without moving to the next one
  if self.isAtEnd():
    result = '\0'
  else:
    result = self.source[self.current]

proc peekNext(self: var Scanner): char =
  # Returns the current + 1 char without moving to the next one
  if self.current + 1 >= self.source.len:
    result = '\0'
  else:
    result = self.source[self.current+1]

proc match(self: var Scanner, expected: char): bool =
  result = true
  if self.isAtEnd():
    result = false
  elif self.source[self.current] != expected:
    result = false
  else:
    # Match found and increment position.
    # Group current & previous chars into a single tokenType
    self.current += 1

# Overloaded methods
proc addToken(self: var Scanner, tokenType: TokenType) =
  # Add token along with metadata
  self.tokens.add(
    Token(
      line: self.line,
      tokenType: tokenType,
      lexeme: self.source[self.start..self.current-1]
    )
  )

proc addStringToken(self: var Scanner, literal: string) =
  # Add string token along with metadata
  self.tokens.add(
    Token(
      line: self.line,
      tokenType: TokenType.STRING,
      lexeme: self.source[self.start..self.current-1],
      strValue: literal
    )
  )

proc addFloatToken(self: var Scanner, literal: float) =
  # Add float token along with metadata
  self.tokens.add(
    Token(
      line: self.line,
      tokenType: TokenType.NUMBER,
      lexeme: self.source[self.start..self.current-1],
      floatValue: literal
    )
  )

proc scanNumber(self: var Scanner) =
  while isDigit(self.peek()): self.advance()

  if self.peek() == '.' and isDigit(self.peekNext()):
    self.advance()
    while isDigit(self.peek()): self.advance()

  let value = self.source[self.start..self.current-1]
  self.addFloatToken(parseFloat(value))

proc scanString(self: var Scanner) =
  while self.peek() != '\"' and not self.isAtEnd():
    if self.peek() == '\L': self.line += 1
    self.advance()

  if self.isAtEnd():
    reportError(self.line, self.source[self.start..self.current], "Unterminated string")

  self.advance()

  # Trim the surrounding quoteself.
  let value = self.source[self.start+1..self.current-2]
  self.addStringToken(value)

proc identifier(self: var Scanner) =
  while isAlphaNumeric(self. peek()): self.advance()
  let
    text: string = self.source[self.start..self.current-1]
    tokenType = if keywords.contains(text): keywords[text]
                else: TokenType.IDENTIFIER
  self.addToken(tokenType)

proc scanToken(self: var Scanner) =
  # Infers the type of lexical token from its string representation
  let c: char = self.advance()
  case c:
    of '(':
      self.addToken(TokenType.LEFT_PAREN)
    of ')':
      self.addToken(TokenType.RIGHT_PAREN)
    of '{':
      self.addToken(TokenType.LEFT_BRACE)
    of '}':
      self.addToken(TokenType.RIGHT_BRACE)
    of ',':
      self.addToken(TokenType.COMMA)
    of '.':
      self.addToken(TokenType.DOT)
    of '-':
      self.addToken(TokenType.MINUS)
    of '+':
      self.addToken(TokenType.PLUS)
    of ';':
      self.addToken(TokenType.SEMICOLON)
    of '*':
      self.addToken(TokenType.STAR)
    of '\r', '\t', ' ': # Ignore whitespace
      discard
    of '\L': # New line char '\n'
      self.line += 1
    of '!':
      self.addToken(if self.match('='): TokenType.BANG_EQUAL else: TokenType.BANG)
    of '=':
      self.addToken(if self.match('='): TokenType.EQUAL_EQUAL else: TokenType.EQUAL)
    of '>':
      self.addToken(if self.match('='): TokenType.GREATER_EQUAL else: TokenType.GREATER)
    of '<':
      self.addToken(if self.match('='): TokenType.LESS_EQUAL else: TokenType.LESS)
    of '/':
      if self.match('/'):
        while(self.peek() != '\L' and not self.isAtEnd()):
          self.advance()
      else: self.addToken(TokenType.SLASH)
    of '\"': self.scanString()
    else:
      if isDigit(c): self.scanNumber()
      elif utils.isAlpha(c): self.identifier()
      else:
        reportError(self.line, self.source[self.start..self.current], "Unrecognized letter $1" % $c)

proc scanTokens*(self: var Scanner): seq[Token] =
  # ScanTokens keeps scanning the source code untils it find the EOF delimiter.
  # It returns a seq of tokens that represents the entire source code.
  while not self.isAtEnd():
    self.start = self.current
    self.scanToken()

  # EOF token
  self.tokens.add(
    Token(
      line: self.line,
      tokenType: TokenType.EOF,
      lexeme: ""
    )
  )
  return self.tokens

proc newScanner*(source: string): Scanner =
  # Create a new Scanner instance
  return Scanner(
    source: source,
    tokens: @[],
    start: 0,
    current: 0,
    line:1
  )
