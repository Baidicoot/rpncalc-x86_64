from ply import lex # pylint: disable=import-error

tokens = (
    'STR',
    'POPEN',
    'PCLOSE',
    'DEFN',
    'ARR',
    'PUSH',
    'INT',
    'IDENT'
)

def t_STR(t):
    r"`(?:\\.|[^`])*`"
    t.value = t.value[1:-1]
    return t

syntax_toks = {
    '->': 'ARR',
    '\'': 'PUSH',
    ';': 'DEFN',
    '(': 'POPEN',
    ')': 'PCLOSE'
}
def t_SYNTAX(t):
    r"->|'|;|\(|\)"
    t.type = syntax_toks[t.value]
    return t

def t_INT(t):
    r"[0-9]+"
    t.value = int(t.value)
    return t

def t_IDENT(t):
    r"(?:[^;'()\-\s]|-(?!>))+"
    return t

def t_NL(t):
    r'\n+'
    t.lexer.lineno += len(t.value)

t_ignore = " \t"

def t_error(t):
    print("unexpected character '", t.value, "'.")
    t.lexer.skip(1)



lexer = lex.lex()