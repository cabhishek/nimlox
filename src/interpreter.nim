import expression, tokenKind, literalKind

type
  Interpreter* = ref object of RootObj

  ValueKind* = enum
    loxString, loxNumber, loxBool, loxNil

  LoxValue* = object
    case kind*: ValueKind
      of loxString: strVal*: string
      of loxNumber: floatVal*: float
      of loxBool: boolVal*: bool
      of loxNil: nil

# Reduce boilerplate code
template `$`*(val: LoxValue): string =
  case val.kind:
    of loxString: val.strVal
    of loxNumber: $val.floatVal
    of loxBool: $val.boolVal
    of loxNil: "nil"

template `!`(val: LoxValue): bool =
  case val.kind:
    of loxNil: false
    of loxBool: not val.boolVal
    else: true

template `+`(left, right: LoxValue): float =
  left.floatVal + right.floatVal

template `&`(left, right: LoxValue): string =
  left.strVal & right.strVal

template `-`(left, right: LoxValue): float =
  left.floatVal - right.floatVal

template `*`(left, right: LoxValue): float =
  left.floatVal * right.floatVal

template `>`(left, right: LoxValue): bool =
  left.floatVal > right.floatVal

template `>=`(left, right: LoxValue): bool =
  left.floatVal >= right.floatVal

template `<`(left, right: LoxValue): bool =
  left.floatVal < right.floatVal

template `<=`(left, right: LoxValue): bool =
  left.floatVal <= right.floatVal

template `==`(left, right: LoxValue): bool =
  left.floatVal == right.floatVal

template `!=`(left, right: LoxValue): bool =
  left.floatVal != right.floatVal

template strType(left, right: LoxValue): bool =
  (left.kind == loxString) and (right.kind == loxString)

# Construct Lox value types
template loxValue(val: string): LoxValue = LoxValue(kind: loxString, strVal: val)
template loxValue(val: float): LoxValue = LoxValue(kind: loxNumber, floatVal: val)
template loxValue(val: bool): LoxValue = LoxValue(kind: loxBool, boolVal: val)
template loxValue(): LoxValue = LoxValue(kind: loxNil)

method evaluate*(self: Interpreter, expr: Expression): LoxValue {.base.} = discard

method evaluate*(self: Interpreter, expr: Literal): LoxValue =
  case expr.kind:
    of litString: result = loxValue(expr.strVal)
    of litNumber: result = loxValue(expr.floatVal)
    of litBool: result = loxValue(expr.boolVal)
    of litNil: result = loxValue()

method evaluate(self: Interpreter, expr: Unary): LoxValue =
  let val = self.evaluate(expr.right)
  case expr.operator.kind:
    of tkMinus:
      result = loxValue(-(val.floatVal))
    of tkBang:
      result = loxValue(!val)
    else: result = loxValue()

method evaluate(self: Interpreter, expr: Binary): LoxValue =
  let
    left = self.evaluate(expr.left)
    right = self.evaluate(expr.right)
  case expr.operator.kind:
    of tkMinus:
      result = loxValue(left - right)
    of tkStar:
      result = loxValue(left * right)
    of tkPlus:
      if strType(left, right):
        result = loxValue(left & right) # String concat
      else:
        result = loxValue(left + right) # Addition
    of tkGreater:
      result = loxValue(left > right)
    of tkGreaterEqual:
      result = loxValue(left >= right)
    of tkLess:
      result = loxValue(left < right)
    of tkLessEqual:
      result = loxValue(left <= right)
    of tkBangEqual:
      result = loxValue(left != right)
    of tkEqualEqual:
      result = loxValue(left == right)
    else: result = loxValue()

