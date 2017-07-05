import os, strutils, utils

proc reportError*(line: int, where: string, msg: string) =
  display("Error: $1" % msg)
  display(indent("Line: $1 Char: $2" % [$line, where], count=2))
