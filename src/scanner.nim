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
proc addToken(s: var Scanner, tokKind: TokenKind) =
  # Add token along with metadata
  s.tokens.add(
    Token(
      line: s.line,
      kind: tokKind,
      lexeme: s.source[s.start..s.current-1]
    )
  )

proc addStringToken(s: var Scanner, literal: string) =
  # Add string token along with metadata
  s.tokens.add(
    Token(
      line: s.line,
      kind: tkString,
      lexeme: s.source[s.start..s.current-1],
      val: literal
    )
  )

proc addFloatToken(s: var Scanner, literal: float) =
  # Add float token along with metadata
  s.tokens.add(
    Token(
      line: s.line,
      kind: tkNumber,
      lexeme: s.source[s.start..s.current-1],
      fVal: literal
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
                 else: tkIdentifier
  s.addToken(tokenKind)

proc scanToken(s: var Scanner) =
  # Infers the type of lexical token from its string representation
  let c: char = s.advance()
  case c:
    of '(':
       s.addToken(tkLeftParen)
    of ')':
       s.addToken(tkRightParen)
    of '{':
       s.addToken(tkLeftBrace)
    of '}':
       s.addToken(tkRightBrace)
    of ',':
       s.addToken(tkComma)
    of '.':
       s.addToken(tkDot)
    of '-':
       s.addToken(tkMinus)
    of '+':
       s.addToken(tkPlus)
    of ';':
       s.addToken(tkSemicolon)
    of '*':
       s.addToken(tkStar)
    of '\r', '\t', ' ': # Ignore whitespace
      discard
    of '\L': # New line char '\n'
      s.line += 1
    of '!':
       s.addToken(if s.match('='): tkBangEqual else: tkBang)
    of '=':
       s.addToken(if s.match('='): tkEqualEqual else: tkEqual)
    of '>':
       s.addToken(if s.match('='): tkGreaterEqual else: tkGreater)
    of '<':
       s.addToken(if s.match('='): tkLessEqual else: tkLess)
    of '/':
      if s.match('/'):
        while(s.peek() != '\L' and not s.isAtEnd()):
          s.advance()
      else: s.addToken(tkSlash)
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
      kind: tkEof,
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
