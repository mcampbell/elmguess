/* File: gulpfile.js */

'use strict';

// grab our gulp packages
var gulp = require('gulp'),
    http = require('http'),
    st = require('st'),
    exec = require('child_process').exec,
    gutil = require('gulp-util'),
    clear = require('clear');

// https://github.com/gulpjs/gulp/blob/master/docs/recipes/delete-files-folder.md
var del = require('del');


// What do run to do our compile
var elm_cmd = 'elm make ./src/Main.elm --output ./dist/bundle.js';


gulp.task('default', ['server', 'watch', 'elm', 'static']);

// Taken from https://github.com/knowthen/elm/tree/master/05%20scorekeeper-starter
gulp.task('watch', function() {
    gulp.watch('**/*.elm', ['elm']);
    gulp.watch('static/*', ['static']);
});

gulp.task('server', function(done) {
    gutil.log(gutil.colors.blue('Starting server at http://localhost:4000'));
    http.createServer(
        st({
            path: __dirname + '/dist',
            index: 'index.html',
            cache: false
        })
    ).listen(4000, done);
});

gulp.task('elm', function(cb) { // cb to let gulp know the task is done; runs async
    exec(elm_cmd, function(err, stdout, stderr) {
        if (err){
            gutil.log(gutil.colors.red('elm make: '),gutil.colors.red(stderr));
        } else {
            gutil.log(gutil.colors.green('elm make: '), gutil.colors.green(stdout));
        }
        cb();
    });
});

gulp.task('static', function() {
    return gulp.src('static/*')
        .pipe(gulp.dest('dist/'))
    ;
});

gulp.task('clean', function() {
    return del( ['dist/'] );
});

