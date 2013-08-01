var fs = require("fs");;
var andromeda = require("./andromeda.nd.js");;
var lodash = require("lodash");;
var first = lodash.first;;
var rest = lodash.rest;;
var rethrow = (function (error){
throw(error);
return false;
});;
var compileByName = (function (name){
return fs.readFile(name,"utf8",(function (error,data){
((error) ? (rethrow(error)) : (false));
var compiled = andromeda(data);;
var outName = (name+".js");;
return fs.writeFile(outName,compiled,(function (error){
((error) ? (rethrow(error)) : (false));
return console.log("Written to",outName);
}));
}));
});;
compileByName(2[process.argv]);
