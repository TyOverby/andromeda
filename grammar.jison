%{
    function mkNode(type, val, start, end){
        return {
            "type": type,
            "value": val,
            "start": start,
            "end": end
        };
    }

    function mkSpecial(type, vals, start, end){
        var toReturn =  {
            "type": type,
            "start": start,
            "end": end
        }
        for(key in vals){
            toReturn[key] = vals[key];
        }
        return toReturn;
    }

    function mkPair(v1, v2){
        return {
            "v1": v1,
            "v2": v2
        };
    }

    function emptyList(){
        return [];
    }

    function emptyObj(){
        return {};
    }
%}

%lex
%%

"'"[a-zA-Z_$]+    {return 'QUOTE_IDENT';}

\s {}
"," {}
"("      { return '('; }
")"      { return ')'; }
"["      { return '['; }
"]"      { return ']'; }
"{"      { return '{'; }
"}"      { return '}'; }
":"      { return ':'; }
"'"      { return 'QUOTE'; }
"#"      { return 'CRUNCH';}

"lambda" { return 'LAMBDA';   }
"begin"  { return 'BEGIN';    }
"cond"   { return 'COND';     }
"define" { return 'DEFINE';   }
"if"     { return 'IF';       }
"let"    { return 'LET';      }
"letrec" { return 'LETREC';   }
"set"    { return 'SET';      }
"switch" { return 'SWITCH';   }
"setp"   { return 'SETP';     }
"getp"   { return 'GETP';     }

"default" { return 'DEFAULT'; }

"break"      { return 'RESERVED'; }
"case"       { return 'RESERVED'; }
"catch"      { return 'RESERVED'; }
"continue"   { return 'RESERVED'; }
"debugger"   { return 'RESERVED'; }
"delete"     { return 'RESERVED'; }
"do"         { return 'RESERVED'; }
"else"       { return 'RESERVED'; }
"finally"    { return 'RESERVED'; }
"for"        { return 'RESERVED'; }
"function"   { return 'RESERVED'; }
"if"         { return 'RESERVED'; }
"in"         { return 'RESERVED'; }
"instanceof" { return 'RESERVED'; }
"new"        { return 'RESERVED'; }
"return"     { return 'RESERVED'; }
"switch"     { return 'RESERVED'; }
// "throw"      { return 'RESERVED'; }
"try"        { return 'RESERVED'; }
"typeof"     { return 'RESERVED'; }
"var"        { return 'RESERVED'; }
"void"       { return 'RESERVED'; }
"while"      { return 'RESERVED'; }
"with"       { return 'RESERVED'; }
"class"      { return 'RESERVED'; }
"enum"       { return 'RESERVED'; }
"export"     { return 'RESERVED'; }
"extends"    { return 'RESERVED'; }
"import"     { return 'RESERVED'; }
"super"      { return 'RESERVED'; }
"implements" { return 'RESERVED'; }
"interface"  { return 'RESERVED'; }
"let"        { return 'RESERVED'; }
"package"    { return 'RESERVED'; }
"private"    { return 'RESERVED'; }
"protected"  { return 'RESERVED'; }
"public"     { return 'RESERVED'; }
"static"     { return 'RESERVED'; }
"yield"      { return 'RESERVED'; }

"macro"      { return 'RESERVED'; }
"compe"      { return 'RESERVED'; }
"defmacro"   { return 'RESERVED'; }


[0-9]+"."[0-9]+([Ee][+-]?[0-9]+)? { return 'NUMBER';        }
[0-9]+                            { return 'NUMBER';        }
\"(\\\"|[^"])*\"                  { return 'STRING';        }
[$_a-zA-Z](\.?[$_a-zA-Z0-9]+)*    { return 'IDENT';         }
[^(){}[\], :.'"]+                 { return 'SPECIAL_IDENT'; }

"."      { return 'DOT'; }
<<EOF>>  { return 'EOF'; }

/lex

%%

file: list EOF { return $list; };

expression: IDENT           { $$ = mkNode('identifier', $IDENT, @IDENT)                    }
          | STRING          { $$ = mkNode('string', $STRING, @STRING)                      }
          | NUMBER          { $$ = mkNode('number', $NUMBER, @NUMBER)                      }

          | lambda          { $$ = $lambda                                                 }
          | begin           { $$ = $begin                                                  }
          | cond            { $$ = $cond                                                   }
          | define          { $$ = $define                                                 }
          | if              { $$ = $if                                                     }
          | let             { $$ = $let                                                    }
          | letrec          { $$ = $letrec                                                 }
          | set             { $$ = $set                                                    }
          | switch          { $$ = $switch                                                 }
          | attribute       { $$ = $attribute                                              }
          | method          { $$ = $method                                                 }

          | sexpr           { $$ = $sexpr                                                  }
          | list_literal    { $$ = $list_literal                                           }
          | quote_ident     { $$ = $quote_ident                                            }
          | obj_literal     { $$ = $obj_literal                                            }
          | SPECIAL_IDENT   { $$ = mkNode('special_ident', $SPECIAL_IDENT, @SPECIAL_IDENT) }
          ;

identifier   : IDENT         { $$ = mkNode('identifier', $IDENT, @IDENT)                    };
special_ident: SPECIAL_IDENT { $$ = mkNode('special_ident', $SPECIAL_IDENT, @SPECIAL_IDENT) };
string       : STRING        { $$ = mkNode('string', $STRING, @STRING)                      };
number       : NUMBER        { $$ = mkNode('number', $NUMBER, @NUMBER)                      };

dot_ident: DOT_IDENT { $$ = mkNode('dot_identifier', $DOT_IDENT, @DOT_IDENT)};

list: list expression { $$ = $list; $$.push($expression); }
    | expression      { $$ = [$expression];               }
    ;

sexpr: '(' list ')' { $$ = mkSpecial('sexpr', {exprs: $list}, @1, @3 ) }
//     | '(' ')'      { $$ = mkSpecial('sexpr', {exprs: []}, @1, @2)     }
     ;

list_literal: '[' list ']' { $$ = mkNode('list', $list, @1, @3)       }
            | '[' ']'      { $$ = mkNode('list', emptyList(), @1, @2) }
            ;

 /*****************
 * OBJECT LITERAL *
 *****************/

key_value_pair: IDENT ':' expression {$$ = mkNode('key_value', mkPair(mkNode('identifier', $IDENT, @1), $expression), @IDENT, @expression) }
              | quote_ident ':' expression {$$ = mkNode('key_value', mkPair($quote_ident, $expression), @quote_ident, @expression)}
              | STRING ':' expression {$$ = mkNode('key_value', mkPair( mkNode('string', $STRING, @1), $expression), @STRING, @expression)}
              ;

kv_pair_list : kv_pair_list key_value_pair {
                $$ = $kv_pair_list, $$.push($key_value_pair);
               }
             | key_value_pair {
                $$ = [$key_value_pair];
               }
             ;

obj_literal: '{' kv_pair_list '}' { $$ = mkNode('obj_lit', $kv_pair_list, @1, @3) }
           | '{' '}'              {  $$ = mkNode('obj_lit', emptyList(), @1, @2)  }
           ;

quote_ident : 'QUOTE_IDENT' {$$ = mkNode('quote_ident', $QUOTE_IDENT, @1)} ;


 /*********
 * LAMBDA *
 *********/

identifier_list : 'IDENT'                 { $$ = [mkNode('identifier', $IDENT, @IDENT)];                      }
                | identifier_list 'IDENT' { $$ = $identifier_list; $$.push(mkNode('identifier', $IDENT, @2)); }
                ;
wrapped_identifier_list: '(' identifier_list ')' { $$ = mkNode('identifier_list', $identifier_list, @1, @3) };

lambda: '(' 'LAMBDA' wrapped_identifier_list list ')' { $$ = mkSpecial('lambda', {vars: $3.value, exprs: $4}, @1, @5) }
      | '(' 'LAMBDA' '(' ')' list ')'                 { $$ = mkSpecial('lambda', {vars: [], exprs: $5}, @1, @6) }
      ;



 /********
 * begin *
 ********/

begin: '(' 'BEGIN' list  ')' { $$ = mkSpecial('begin',{exprs: $list}, @1, @4) };

 /*******
 * COND *
 *******/
cond_pair: '(' expression expression ')' { $$ = mkSpecial('cond_pair', {l: $2, r: $3}, @1, @4) };

cond_pair_list: cond_pair                { $$ = [$cond_pair]; }
              | cond_pair_list cond_pair { $$ = $cond_pair_list; $$.push($cond_pair) }
              ;

cond: '(' 'COND' cond_pair_list ')' { $$ = mkSpecial('cond', {pairs: $cond_pair_list}, @1, @4) };

 /*********
 * define *
 *********/

define: '(' 'DEFINE' IDENT expression ')' { $$ = mkSpecial('define', {l: mkNode('identifier', $IDENT, @IDENT), r: $expression}, @1, @5) };


 /*****
 * if *
 *****/

if: '(' 'IF' expression expression expression ')' { $$ = mkSpecial('if', {cond: $3, thn: $4, els: $5}, @1, @6) };


 /******
 * let *
 ******/

let_pair: '(' identifier expression ')' { $$ = mkSpecial('let_pair', {l: $2, r: $3}, @1, @4) };

let_list: let_pair          { $$ = [$let_pair]                  }
        | let_list let_pair { $$ = $let_list; $$.push($let_pair) }
        ;

let: '(' 'LET' '(' ')' list ')'          { $$ = mkSpecial('let', {pairs: [], exprs: $list},@1, @6)        }
   | '(' 'LET' '(' let_list ')' list ')' { $$ = mkSpecial('let', {pairs: $let_list, exprs:$list}, @1, @7) }
   ;

 /*********
 * letrec *
 *********/


let: '(' 'LETREC' '(' ')' list ')'          { $$ = mkSpecial('letrec', {pairs: [], exprs: $list},@1, @6)        }
   | '(' 'LETREC' '(' let_list ')' list ')' { $$ = mkSpecial('letrec', {pairs: $let_list, exprs:$list}, @1, @7) }
   ;


 /******
 * set *
 *****/


set: '(' 'SET' identifier  expression ')'           { $$ = mkSpecial('set', {ident: $identifier, value: $expression},  @1, @5)  }
   | '(' 'SET' identifier expression expression ')' { $$ = mkSpecial('setp', {ident: $identifier, obj: $4, value: $5 }, @1, @6) }
   ;

 /*********
 * switch *
 *********/

switch_pair: '(' expression expression ')'  { $$ = mkSpecial('switch_pair', {l: $2, r: $3 }, @1, @4) };

default_pair: '(' 'DEFAULT' expression  ')' { $$ = mkSpecial('default_pair', {expr: $expression}, @1, @4)};

switch_list: switch_pair             { $$ = [$switch_pair]                       }
           | switch_list switch_pair { $$ = $switch_list; $$.push($switch_pair); }
           ;



switch: '(' 'SWITCH' expression switch_list default_pair ')' { $$ = mkSpecial('switch', {expr: $expression, pairs: $switch_list, default: $default_pair}, @1, @6)};

 /************
 * accessors *
 ************/

attribute: '(' 'CRUNCH' identifier expression ')' { $$ = mkSpecial('attribute', {attr: $identifier, expr: $expression},@1, @5) };

method: '(' 'DOT' identifier expression list ')'{ $$ = mkSpecial('method', {name: $identifier, expr: $expression, args: $list}, @1, @6 )}
      | '(' 'DOT' identifier expression ')'     { $$ = mkSpecial('method', {name: $identifier, expr: $expression , args: []}, @1, @5)   }
      ;

 /*************
 * properties *
 *************/

 setp: '(' 'SETP' expression expression expression ')' { $$ = mkSpecial('setp', {obj: $3, pName: $4, value: $5}, @1, @6) };
 getp: '(' 'GETP' expression expression ')'            { $$ = mkSpecial('getp', {obj: $3, pName: $4}, @1, @5)            };

