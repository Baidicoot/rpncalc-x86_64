
# parsetab.py
# This file is automatically generated. Do not edit.
# pylint: disable=W,C,R
_tabversion = '3.10'

_lr_method = 'LALR'

_lr_signature = 'ARR DEFN IDENT INT PCLOSE POPEN PUSH STRstatements : statement statementsstatements :statement : PUSH expressionstatement : POPEN IDENT DEFN statements PCLOSEstatement : POPEN IDENT DEFN identifiers ARR statements PCLOSEstatement : expressionexpression : INTexpression : STRexpression : IDENTexpression : POPEN identifiers ARR statements PCLOSEidentifiers : IDENT identifiersidentifiers :'
    
_lr_action_items = {'$end':([0,1,2,4,6,7,8,9,10,22,24,26,],[-2,0,-2,-6,-9,-7,-8,-1,-3,-4,-10,-5,]),'PUSH':([0,2,4,6,7,8,10,15,17,18,22,23,24,26,],[3,3,-6,-9,-7,-8,-3,3,3,-9,-4,3,-10,-5,]),'POPEN':([0,2,3,4,6,7,8,10,15,17,18,22,23,24,26,],[5,5,11,-6,-9,-7,-8,-3,5,5,-9,-4,5,-10,-5,]),'INT':([0,2,3,4,6,7,8,10,15,17,18,22,23,24,26,],[7,7,7,-6,-9,-7,-8,-3,7,7,-9,-4,7,-10,-5,]),'STR':([0,2,3,4,6,7,8,10,15,17,18,22,23,24,26,],[8,8,8,-6,-9,-7,-8,-3,8,8,-9,-4,8,-10,-5,]),'IDENT':([0,2,3,4,5,6,7,8,10,11,12,14,15,17,18,22,23,24,26,],[6,6,6,-6,12,-9,-7,-8,-3,14,14,14,18,6,14,-4,6,-10,-5,]),'PCLOSE':([2,4,6,7,8,9,10,15,17,18,19,21,22,23,24,25,26,],[-2,-6,-9,-7,-8,-1,-3,-2,-2,-9,22,24,-4,-2,-10,26,-5,]),'ARR':([5,11,12,13,14,15,16,18,20,],[-12,-12,-12,17,-12,-12,-11,-12,23,]),'DEFN':([12,],[15,]),}

_lr_action = {}
for _k, _v in _lr_action_items.items():
   for _x,_y in zip(_v[0],_v[1]):
      if not _x in _lr_action:  _lr_action[_x] = {}
      _lr_action[_x][_k] = _y
del _lr_action_items

_lr_goto_items = {'statements':([0,2,15,17,23,],[1,9,19,21,25,]),'statement':([0,2,15,17,23,],[2,2,2,2,2,]),'expression':([0,2,3,15,17,23,],[4,4,10,4,4,4,]),'identifiers':([5,11,12,14,15,18,],[13,13,16,16,20,16,]),}

_lr_goto = {}
for _k, _v in _lr_goto_items.items():
   for _x, _y in zip(_v[0], _v[1]):
       if not _x in _lr_goto: _lr_goto[_x] = {}
       _lr_goto[_x][_k] = _y
del _lr_goto_items
_lr_productions = [
  ("S' -> statements","S'",1,None,None,None),
  ('statements -> statement statements','statements',2,'p_stmts_cons','parser.py',29),
  ('statements -> <empty>','statements',0,'p_stmts_nil','parser.py',33),
  ('statement -> PUSH expression','statement',2,'p_stmt_push','parser.py',37),
  ('statement -> POPEN IDENT DEFN statements PCLOSE','statement',5,'p_stmt_defn','parser.py',41),
  ('statement -> POPEN IDENT DEFN identifiers ARR statements PCLOSE','statement',7,'p_expr_lambda_defn','parser.py',45),
  ('statement -> expression','statement',1,'p_stmt_expr','parser.py',49),
  ('expression -> INT','expression',1,'p_expr_int','parser.py',53),
  ('expression -> STR','expression',1,'p_expr_str','parser.py',57),
  ('expression -> IDENT','expression',1,'p_expr_ident','parser.py',61),
  ('expression -> POPEN identifiers ARR statements PCLOSE','expression',5,'p_expr_lambda','parser.py',65),
  ('identifiers -> IDENT identifiers','identifiers',2,'p_idents_cons','parser.py',69),
  ('identifiers -> <empty>','identifiers',0,'p_idents_nil','parser.py',73),
]
