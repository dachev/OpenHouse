#!/usr/bin/env node

var fs      = require('fs');
var path    = require('path');
var sys     = require('sys');
var child   = require('child_process');
var sprintf = require('./sprintf').sprintf;

var basedir = process.ARGV[2];
if (!basedir) {
    sys.puts('Missing or invalid argument: basedir');
    process.exit(1);
}

function convertFiles(basedir) {
    fs.readdir(basedir, function(err, files) {
        for (var i = 0; i < files.length; i++) (function(file) {
            fs.stat(file, function(err, stats) {
                if (stats.isDirectory()) {
                    convertFiles(file);
                }
                else if (stats.isFile()) {
                    var fileName = path.basename(file, '.png');
                    var extName  = path.extname(file);
                    var dirName  = path.dirname(file);
                    
                    if (!fileName || !extName || extName != '.png') {
                        return;
                    }
                    
                    var newFile = path.join(dirName, fileName);
                    var command = sprintf('convert %s.png %s.jpg', newFile, newFile);
                    child.exec(command, function(error, stdout, stderr) {
                        if (error) {
                            sys.puts(command + ':');
                            sys.puts(sys.inspect(error));
                            sys.puts('\n\n');
                            return;
                        }
                        
                        fs.unlink(file, function (err) {});
                    });
                }
            });
        })(path.join(basedir, files[i]));
    });
}
convertFiles(basedir);





