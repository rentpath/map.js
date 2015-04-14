'use strict';

var gulp = require('gulp');
var coffee = require('gulp-coffee')
var gutil = require('gulp-util')
var del = require('del');
var sourcemaps = require('gulp-sourcemaps')

gulp.task('clean-dist', function (cb) {
  del('dist/', cb);
});

gulp.task('clean-demo', function (cb) {
  del('app/js', cb);
});

gulp.task('build-dist', ['clean-dist'], function() {
  gulp.src([ 'app/coffeescript/**/*.coffee', '!app/coffeescript/demo/**' ])
    .pipe(coffee({bare: true}).on('error', gutil.log))
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

