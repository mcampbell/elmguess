/* File: gulpfile.js */

'use strict';

// grab our gulp packages
var gulp = require('gulp'),
    http = require('http'),
    st = require('st'),
    exec = require('child_process').exec,
    gutil = require('gulp-util'),
    clear = require('clear');

// What do run to do our compile
var cmd = 'elm make ./src/Main.elm --output ./static/bundle.js';

gulp.task('default', ['server', 'watch', 'elm']);

// Taken from https://github.com/knowthen/elm/tree/master/05%20scorekeeper-starter
gulp.task('watch', function() {
    gulp.watch('**/*.elm', ['elm']);
});

gulp.task('server', function(done) {
    gutil.log(gutil.colors.blue('Starting server at http://localhost:4000'));
    http.createServer(
        st({
            path: __dirname + '/static',
            index: 'index.html',
            cache: false
        })
    ).listen(4000, done);
});

gulp.task('elm', function(cb) {
    exec(cmd, function(err, stdout, stderr) {
        if (err){
            gutil.log(gutil.colors.red('elm make: '),gutil.colors.red(stderr));
        } else {
            gutil.log(gutil.colors.green('elm make: '), gutil.colors.green(stdout));
        }
        cb();  // what does this do
    });
});
