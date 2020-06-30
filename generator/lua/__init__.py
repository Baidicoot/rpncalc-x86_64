import generator
import os
from parser.AST import *
from sys import path
from misc import Relative, Absolute

class CompCtx:
    def __init__(self, indent, scope, extern):
        self.i = indent
        self.scope = scope
        self.extern = extern
    
    def is_local(self, name):
        if name in self.scope[-1]:
            return True
        else:
            return False
    
    def in_scope(self, name):
        for s in self.scope:
            if name in s:
                return True
        return False
    
    def setvar(self, name):
        if self.is_local(name):
            return name + " = "
        else:
            return "local " + name + " = "
    
    def register(self, name):
        self.scope[-1].append(name)
    
    def enter(self, args):
        self.i += 1
        self.scope.append(args)
    
    def indent(self):
        return "  "*self.i
    
    def exit(self):
        self.i -= 1
        self.scope.pop()

def generateLam(args, body, ctx):
    ctx.enter(args)
    out = "{func=function(argdata)\n" + ctx.indent() + "local stack = {__rpncc_type=\"stack\"}\n"
    for i, arg in enumerate(args):
        out += ctx.indent()
        out += "local " + arg + " = argdata[" + str(i+1) + "]\n"
    out += generate(body, ctx) + ctx.indent() + "return stack\n"
    ctx.exit()
    out += ctx.indent() + "end, args={}, __rpncc_type=\"closure\", nargs=" + str(len(args)) + "}"
    return out

def generatePush(expr, ctx):
    out = ctx.indent()
    if expr.__class__ == Int:
        out += "table.insert(stack, " + str(expr.val) + ")\n"
    elif expr.__class__ == Str:
        out += "table.insert(stack, \"" + expr.val + "\")\n"
    elif expr.__class__ == Ident:
        if expr.name in ctx.extern.keys():
            ident, nargs = ctx.extern[expr.name]
            out += "table.insert(stack, {func=" + ident + ", args={}, __rpncc_type=\"closure\", nargs=" + str(nargs) + "})\n"
        else:
            if not ctx.in_scope(expr.name):
                raise BaseException("variable " + expr.name + " not in scope")
            out += "table.insert(stack, " + expr.name + ")\n"
    elif expr.__class__ == Lambda:
        out += "table.insert(stack, " + generateLam(expr.args, expr.body, ctx) + ")\n"
    return out

def generateApp(expr, ctx):
    out = ctx.indent()
    if expr.__class__ == Int:
        out += "table.insert(stack, " + str(expr.val) + ")\n"
    elif expr.__class__ == Str:
        out += "table.insert(stack, \"" + expr.val + "\")\n"
    elif expr.__class__ == Ident:
        if expr.name in ctx.extern.keys():
            ident, nargs = ctx.extern[expr.name]
            out += "apply(stack, {func=" + ident + ", args={}, __rpncc_type=\"closure\", nargs=" + str(nargs) + "})\n"
        else:
            if not ctx.in_scope(expr.name):
                raise BaseException("variable " + expr.name + " not in scope")
            out += "apply(stack, " + expr.name + ")\n"
    elif expr.__class__ == Lambda:
        out += "apply(stack, " + generateLam(expr.args, expr.body, ctx) + ")\n"
    return out

def generate(stmts, ctx):
    out = ""
    for stmt in stmts:
        if stmt.__class__ == Definition:
            out += ctx.setvar(stmt.ident)
            ctx.register(stmt.ident)
            ctx.enter([])
            out += "(" + generateLam([], stmt.body, ctx) + ").func({})\n"
            ctx.exit()
        elif stmt.__class__ == Push:
            out += generatePush(stmt.elem, ctx)
        elif stmt.__class__ == SingleExpr:
            out += generateApp(stmt.elem, ctx)
    return out

@generator.libgenerator("lua")
def libgen(input, output, flags, ext):
    currdir = os.getcwd()

    out = ""
    for sym, ast in input.getast().items():
        out += "local " + sym + " = function()\n  local stack = {__rpncc_type=\"stack\"}\n" + generate(ast, CompCtx(1, [[]], ext)) + "  return stack\nend\n"
    
    os.chdir(path[0] + "/generator/lua")

    fout = open("build/"+output, "w+")
    fout.write(out)
    fout.close()

    os.chdir(currdir)

@generator.generator("lua")
def gen(input, output, flags, extern, links):
    out = "local _start = function()\n  local stack = {__rpncc_type=\"stack\"}\n"
    ctx = CompCtx(1, [[]], extern)
    out += generate(input, ctx)
    out += "  return stack\nend\n"
    out += """
for i, x in ipairs(_start()) do
  print(x)
end
"""

    currdir = os.getcwd()

    os.chdir(path[0] + "/generator/lua")

    fout = open(currdir+"/"+output, "w+")
    links.insert(0, Relative("apply.lua"))
    for fpath in links:
        actual = fpath.path if fpath.__class__ == Absolute else "build/"+fpath.path
        with open(actual) as file:
            fout.write(file.read())
            fout.write("\n")
    fout.write(out)
    fout.close()

    os.chdir(currdir)