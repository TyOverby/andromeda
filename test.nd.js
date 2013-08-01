// ./bootstrap/test.lx
'use strict';var lux = require('./andromeda.nd.js');
var test = (function(program,should) {
var rem = (function(str) {
return str.replace(RegExp('\\s+', 'g'), '');
});
return (function(t) {
var compiled = rem(lux(program));
var noEnd = compiled.substring(0, (compiled.length - 1));
t.equals(noEnd, rem(should));
return t.done();
});
});
exports.testString1 = test('\"hello world\"', '\"hello world\"');
exports.testString2 = test('\"\\\"', '\"\\\"');
exports.testNumber1 = test('25', '25');
exports.testNumber2 = test('25.3', '25.3');
exports.testNumber3 = test('25.0E35', '25.0E35');
exports.testQuotIdent1 = test("'hello", "'hello'");
exports.testLambda1 = test('(lambda () 5)', '(function () {return 5;})');
exports.testLambda2 = test('(lambda (x) x)', '(function (x) {return x;})');
exports.testLambda3 = test('(lambda (x y) x y)', '(function (x, y) {x; return y;})');
exports.testBegin1 = test('(begin x y z)', '(function () {x; y; return z;})()');
exports.testCond1 = test('(cond (f 1) (b 2))', '(function (){if(f){return 1;} else if(b){return 2;}})()');
exports.testDefine1 = test('(define x 1)', 'var x = 1;');
exports.testDefine2 = test('(define f (lambda (x) x))', 'var f = (function (x) {return x;});');
exports.testIf1 = test('(if x a b)', '((x) ? (a) : (b))');
exports.testLet1 = test('(let ((a b) (c d)) foo bar)', '(function (a,c){foo;return bar;}(b,d))');
exports.testLetrec1 = test('(letrec ((a b) (c d)) foo bar)', '(function (){var a=b; var c=d; foo;return bar;}())');
exports.testSet1 = test('(set a 5)', '(a=5)');
exports.testSet1 = test('(set this.a 5)', '(this.a=5)');
exports.testSwitch1 = test('(switch a (b c) (d e) (default 10))', '(function () {switch(a){case b: return c; break; case d: return e; break; default: return 10; break;}}())');
exports.testAttribute1 = test('(#attr obj)', 'obj.attr');
exports.testMethod1 = test('(.method obj 1 2)', 'obj.method(1,2)');
exports.testMethod1 = test('(.method obj)', 'obj.method()');
exports.testSexpr1 = test('(f)', 'f()');
exports.testSexpr2 = test('(f 1 a b)', 'f(1,a,b)');
exports.testAddition1 = test('(+)', '0');
exports.testAddition2 = test('(+ 5)', '5');
exports.testAddition3 = test('(+ 1 2 3 4)', '(1+2+3+4)');
exports.testThunk1 = test('(thunk 5)', '(function () {return 5;})');
exports.testThunk2 = test('(thunk (f) 5)', '(function () {f(); return 5;})');
