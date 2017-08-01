import os, strutils, tables
from utils import newLine

# String templates
const
  typeDesc = "$1* = ref object of $2"
  propDesc = "$1*: $2"
  methodDesc = "method accept*[T](expr: $1, v: Visitor): T = return v.visit$1Expression(expr)"

proc addImport(content: var string, module: string) =
  content.add("import token")
  content.add(newLine(count=2))

proc addTypes(content: var string, types: Table[string, string]) =
  content.add("type")
  content.add(newLine())
  content.add(indent(typeDesc % ["Visitor", "RootObj"], count=2))
  content.add(newLine(count=2))
  content.add(indent(typeDesc % ["Expression", "RootObj"], count=2))
  content.add(newLine(count=2))

  for objName, properties in pairs(types):
    content.add(indent(typeDesc % [objName, "Expression"], count=2))
    content.add(newLine())
    for property in properties.split(','):
      let parts = property.strip.split(' ')
      content.add(indent(propDesc % [parts[0], parts[1]], count=4))
      content.add(newLine())
    content.add(newLine())

proc addMethods(content: var string, types: Table[string, string]) =
  for param in types.keys:
    content.add(methodDesc % param)
    content.add(newLine(count=2))

proc addAbstractMethod(content: var string) =
  content.add("method accept*[T](expr: Expression, v: Visitor): T = quit(\"Overide me\")")
  content.add(newLine(count=2))

proc generateAst(dirName: string) =
  let outputDir = getCurrentDir() / dirName
  echo "Output directory: $1" % outputDir
  discard existsOrCreateDir(outputDir)
  const types = {
    "Binary"   : "left Expression, operator Token, right Expression",
    "Grouping" : "expression Expression",
    "Literal"  : "value string",
    "Unary"    : "operator Token, right Expression"
  }.toTable

  var content = ""
  content.addImport("token")
  content.addTypes(types)
  content.addAbstractMethod()
  content.addMethods(types)

  # Finally, write to file
  writeFile(outputDir / "expression.nim", content)

when isMainModule:
  let params: seq[string] = commandLineParams()
  if params.len != 1:
    quit("Usage: astgen <output directory>")
  generateAst(params[0])
