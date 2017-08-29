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

proc `$`*(val: LoxValue): string =
  case val.kind:
    of loxString: result = val.strVal
    of loxNumber: result = $val.floatVal
    of loxBool: result = $val.boolVal
    of loxNil: result = "nil"

proc `not`(val: LoxValue): bool =
  case val.kind:
    of loxNil: result = false
    of loxBool: result = not val.boolVal
    else: result = true

proc `+`(left, right: LoxValue): float = 
  result = left.floatVal + right.floatVal

proc `&`(left, right: LoxValue): string = 
  result = left.strVal & right.strVal

proc `-`(left, right: LoxValue): float = 
  result = left.floatVal - right.floatVal

proc `*`(left, right: LoxValue): float = 
  result = left.floatVal * right.floatVal

proc strType(left, right: LoxValue): bool = 
  result = (left.kind == loxString) and (right.kind == loxString)

# Reduce boilerplate code
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
      result = loxValue(not val)
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
        result = loxValue(left & right)
      else:
        result = loxValue(left + right)
    else: result = loxValue()


