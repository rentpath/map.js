'use strict';

var gulp = require('gulp');
var coffee = require('gulp-coffee')
var gutil = require('gulp-util')
var del = require('del');
var sourcemaps = require('gulp-sourcemaps');
var wrap = require("gulp-wrap-function");
var wrapAMD = require('gulp-wrap-amd');

gulp.task('clean-dist', function (cb) {
  del.sync('dist/');
  cb();
});

gulp.task('clean-demo', function (cb) {
  del.sync('app/js');
  cb();
});

gulp.task('build-dist', ['clean-dist','wrap-amd-dist'], function() {
  gulp.src([ 'app/coffeescript/**/*.coffee', '!app/coffeescript/demo/**' ])
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('dist/'));
});

gulp.task('wrap-amd-dist', function() {
  gulp.src('app/coffeescript/marker_with_label.js')
    .pipe(wrap((function (file) {
      // Wrap file in an anonymous function which prevents it from using `window.google` until it's ready.
      return "function () {\n" + file + "\nreturn MarkerWithLabel;\n}";
    })))
    .pipe(wrapAMD())
    .pipe(gulp.dest('dist/'));
});

gulp.task('build-demo', ['clean-demo'], function() {
  gulp.src('app/coffeescript/**/*.coffee')
    .pipe(sourcemaps.init())
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('app/js'));
});

gulp.task('build', ['build-dist', 'build-demo'], function() { });

gulp.task('dist', ['build-dist'], function() { });

gulp.task('default', ['build'], function () {
  var watcher = gulp.watch(['app/coffeescript/**/*.coffee'], ['build']);

  // adds a space to the output - useful to see that it triggerd in terminal.
  watcher.on('change', function (event) {
    console.log("");
  });
});
