#! /usr/bin/env node

var fs = require("fs");
var exec = require("child_process").exec;

var checkShebang = function () {
    var data = fs.readFileSync("./andr.nd.js", 'utf8');

    var firstLine = data.split('\n')[0];
    if(-1 === firstLine.indexOf("#! /usr/bin/env node")) {
        throw new Error("Missing shebang on andr.nd.js");
    }
};

var checkCompile = function () {
    var list = ["./andromeda.nd", "./test.nd"];
    list.forEach(function (file) {
        exec("node ./andr.nd.js " + file, function (error, stdout, stderr){
            if(error) throw error;
            console.log(stdout);
            console.error(stderr);
        });
    });
};

var runTests = function () {
    exec("npm test", function (error, stdout, stderr){
        if(error) throw error;
        console.log(stdout);
        console.error(stderr);
    });
}

checkShebang();
checkCompile();
runTests();
