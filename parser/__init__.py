from ply import yacc # pylint: disable=import-error
from parser.AST import *
from parser.tokenizer import tokens

"""
RPNCalc64 BNF v2

program     : decls statements

decls       : decl decls
            |

decl        : DECL IMPORT IDENT PCLOSE
            | DECL INCLUDE IDENT PCLOSE

statements  : statement statements
            |

statement   : PUSH expression
            | POPEN IDENT DEFN statements PCLOSE
            | POPEN IDENT DEFN identifiers ARR statements PCLOSE
            | expression

expression  : INT
            | STR
            | IDENT
            | POPEN identifiers ARR statements PCLOSE
            

identifiers : IDENT identifiers
            |
"""

def p_program(p):
    'program : decls statements'
    p[0] = (p[1], p[2])

def p_decls_cons(p):
    'decls : decl decls'
    p[0] = [p[1]] + p[2]

def p_decls_nil(p):
    'decls :'
    p[0] = []

def p_import(p):
    'decl : DOPEN IMPORT IDENT DCLOSE'
    p[0] = Import(p[3])

def p_include(p):
    'decl : DOPEN INCLUDE IDENT DCLOSE'
    p[0] = Include(p[3])

def p_stmts_cons(p):
    'statements : statement statements'
    p[0] = [p[1]] + p[2]

def p_stmts_nil(p):
    'statements :'
    p[0] = []

def p_stmt_push(p):
    'statement : PUSH expression'
    p[0] = Push(p[2])

def p_stmt_defn(p):
    'statement : POPEN IDENT DEFN statements PCLOSE'
    p[0] = Definition(p[2], p[4])

def p_expr_lambda_defn(p):
    'statement : POPEN IDENT DEFN identifiers ARR statements PCLOSE'
    p[0] = Definition(p[2], [Push(Lambda(p[4], p[6]))])

def p_stmt_expr(p):
    'statement : expression'
    p[0] = SingleExpr(p[1])

def p_expr_int(p):
    'expression : INT'
    p[0] = Int(p[1])

def p_expr_str(p):
    'expression : STR'
    p[0] = Str(p[1])

def p_expr_ident(p):
    'expression : IDENT'
    p[0] = Ident(p[1])

def p_expr_lambda(p):
    'expression : POPEN identifiers ARR statements PCLOSE'
    p[0] = Lambda(p[2], p[4])

def p_idents_cons(p):
    'identifiers : IDENT identifiers'
    p[0] = [p[1]] + p[2]

def p_idents_nil(p):
    'identifiers :'
    p[0] = []

def p_error(p):
    print("Syntax error in input:", p)

def getexternal(decls):
    imprts = []
    includes = []
    for d in decls:
        if d.__class__ == Import:
            imprts.append(d.name)
        elif d.__class__ == Include:
            includes.append(d.name)
        else:
            raise BaseException('INVALID DECLARATION '+str(d))
    return imprts, includes

parser = yacc.yacc()