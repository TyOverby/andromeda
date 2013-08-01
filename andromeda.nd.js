var grammar = require("./grammar.js");;
var lodash = require("lodash");;
var forEach = lodash.forEach;;
var init = lodash.initial;;
var first = lodash.first;;
var last = lodash.last;;
var tail = lodash.tail;;
var mkstring = (function (arr,start,sep,end,mapfn){
(mapfn = (mapfn||(function (x){
return x;
})));
var build = start;;
forEach(init(arr),(function (elem){
return (build = (build+mapfn(elem)+sep));
}));
(((!((arr.length===0)))) ? ((build = (build+mapfn(last(arr))))) : (false));
(build = (build+end));
return build;
});;
var buildExprs = (function (exprs){
var build = "";;
(build = (build+mkstring(init(exprs),"","","",(function (n){
return (compile(n)+";\n");
}))));
(build = (build+"return "+compile(last(exprs))+";\n"));
return build;
});;
var error = (function (msg){
throw(Error(msg));
return false;
});;
var cLambda = (function (node){
var build = "(function ";;
(build = (build+mkstring(node.vars,"(",",","){\n",compile)));
(build = (build+buildExprs(node.exprs)));
return (build+"})");
});;
var cBegin = (function (node){
(node.vars = []);
return (cLambda(node)+"()");
});;
var cCond = (function (node){
var build = "(function () {\n";;
var f = first(node.pairs);;
(build = (build+"if ("+compile(f.l)+") {\n return "+compile(f.r)+";\n} "));
forEach(tail(node.pairs),(function (pair){
return (build = (build+"else if ("+compile(pair.l)+") { \n return "+compile(pair.r)+";\n "));
}));
return (build+"\n}})()");
});;
var cDefine = (function (node){
return ("var "+compile(node.l)+" = "+compile(node.r)+";");
});;
var cIf = (function (node){
return ("(("+compile(node.cond)+") ? ("+compile(node.thn)+") : ("+compile(node.els)+"))");
});;
var cLet = (function (node){
var build = "(function ";;
(build = (build+mkstring(node.pairs,"(",",",") {\n",(function (pair){
return compile(pair.l);
}))));
(build = (build+buildExprs(node.exprs)));
return (build+"}"+mkstring(node.pairs,"(",",","))",(function (pair){
return compile(pair.r);
})));
});;
var cLetrec = (function (node){
var build = "(function () {";;
(build = (build+mkstring(node.pairs,"","","",(function (node){
return ("var "+compile(node.l)+" = "+compile(node.r)+";\n");
}))));
(build = (build+buildExprs(node.exprs)));
return (build+"}())");
});;
var cSet = (function (node){
return ("("+compile(node.ident)+" = "+compile(node.value)+")");
});;
var cSwitch = (function (node){
var build = "(function () {\n";;
(build = (build+"switch ("+compile(node.expr)+"){\n"+mkstring(node.pairs,"","","",(function (pair){
return ("case "+compile(pair.l)+":\n return "+compile(pair.r)+";\nbreak;");
}))));
return (build+"default:\nreturn "+compile(node.default.expr)+";\nbreak;\n}}())");
});;
var cAttribute = (function (node){
return (compile(node.expr)+"."+compile(node.attr));
});;
var cMethod = (function (node){
return (compile(node.expr)+"."+compile(node.name)+mkstring(node.args,"(",",",")",compile));
});;
var cListLiteral = (function (node){
return mkstring(node.value,"[",",","]",compile);
});;
var cSexpr = (function (node){
var f = first(node.exprs);;
var rst = tail(node.exprs);;
var squash = (function (symbol,def){
return (function () {
switch (rst.length){
case 0:
 return def;
break;case 1:
 return compile(first(rst));
break;default:
return mkstring(rst,"(",symbol,")",compile);
break;
}}());
});;
return (function () {
switch (f.type){
case 'special_ident':
 return (function () {
switch (f.value){
case "+":
 return squash("+","0");
break;case "-":
 return squash("-","0");
break;case "*":
 return squash("*","1");
break;case "/":
 return squash("/","1");
break;case "=":
 return ("("+compile(first(rst))+"==="+compile(first(tail(rst)))+")");
break;default:
return error(("SPECIAL IDENTIFIER NOT VALID: "+JSON.stringify(node)));
break;
}}());
break;case 'identifier':
 return (function () {
switch (f.value){
case "or":
 return squash("||","false");
break;case "and":
 return squash("&&","true");
break;case "thunk":
 return compile({type:"lambda",vars:[],exprs:rst});
break;case "cat":
 return squash("+","\"\"");
break;case "nth":
 return (compile(first(tail(rst)))+"["+compile(first(rst))+"]");
break;case "not":
 return ("(!("+compile(first(rst))+"))");
break;default:
return (compile(f)+mkstring(rst,"(",",",")",compile));
break;
}}());
break;default:
return (compile(f)+mkstring(rst,"(",",",")",compile));
break;
}}());
});;
var cList = (function (node){
return mkstring(node.value,"[",",","]",compile);
});;
var cObj = (function (node){
return mkstring(node.value,"{",",","}",(function (kvp){
return (compile(kvp.value.v1)+":"+compile(kvp.value.v2));
}));
});;
var compile = (function (node){
return (function () {
switch (node.type){
case 'string':
 return node.value;
break;case 'number':
 return node.value;
break;case 'quote_ident':
 return (node.value+"'");
break;case 'identifier':
 return node.value;
break;case 'lambda':
 return cLambda(node);
break;case 'begin':
 return cBegin(node);
break;case 'cond':
 return cCond(node);
break;case 'define':
 return cDefine(node);
break;case 'if':
 return cIf(node);
break;case 'let':
 return cLet(node);
break;case 'letrec':
 return cLetrec(node);
break;case 'set':
 return cSet(node);
break;case 'switch':
 return cSwitch(node);
break;case 'thunk':
 return cThunk(node);
break;case 'attribute':
 return cAttribute(node);
break;case 'method':
 return cMethod(node);
break;case 'sexpr':
 return cSexpr(node);
break;case 'list':
 return cList(node);
break;case 'obj_lit':
 return cObj(node);
break;default:
return error(("CAN NOT MATCH "+node.type+"\n"+JSON.stringify(node)));
break;
}}());
});;
var andromeda = (function (program){
return mkstring(grammar.parse(program),"",";\n",";\n",compile);
});;
(module.exports = andromeda);
