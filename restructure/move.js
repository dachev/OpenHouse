#!/usr/bin/env node

var fs   = require('fs');
var path = require('path');
var sys  = require('sys');

var basedir = process.ARGV[2];
if (!basedir) {
    sys.puts('Missing or invalid argument: basedir');
    process.exit(1);
}

function moveFile(src, dest) {
    try {
        fs.renameSync(src, dest);
    } catch(e) {
        return false;
    }
    
    return true;
}

function maybeMakeRecursiveDirSync(dest) {
    var nibbles = dest.split('/');
    
    for (var i = 0; i < nibbles.length; i++) {
        var dir = path.join.apply(path, nibbles.slice(0, i+1));
        
        if (!dir) { continue; }
        
        try {
            var stats = fs.statSync(dir);
            
            // continue with traversal
            if (stats.isDirectory()) {
                continue;
            }
            
            //error: exists but not a dir
            return false;
        } catch(ex1) {
            try { fs.mkdirSync(dir, 0744); }
            catch(ex2) { return false; };
        }
    };
    
    return true;
}

function moveFiles(basedir) {
    var files = fs.readdirSync(basedir);
    
    for (var i = 0; i < files.length; i++) {
        var file = path.join(basedir, files[i]);
        
        try {
            var stats = fs.statSync(file);
            if (!stats.isFile()) {
                continue;
            }
            
            var fileName = path.basename(file);
            var fNibble  = fileName.substr(0,2).toUpperCase();
            var sNibble  = fileName.substr(2,2).toUpperCase();
            
            if (!fNibble || !sNibble) {
                continue;
            }
            
            var destdir = path.join(basedir, fNibble, sNibble);
            if (!maybeMakeRecursiveDirSync(destdir)) {
                continue;
            }
            
            var src  = path.join(basedir, fileName);
            var dest = path.join(destdir, fileName);
            moveFile(src, dest);
        } catch(e) {
            continue;
        }
    }
}
moveFiles(basedir);





