'use strict';

var gulp = require('gulp');
var coffee = require('gulp-coffee')
var gutil = require('gulp-util')
var sourcemaps = require('gulp-sourcemaps')
var del = require('del');

gulp.task('clean-dist', function (cb) {
  del('dist/', cb);
});

gulp.task('dist', ['clean-dist'], function() {
  gulp.src([ 'src/**/*.coffee' ])
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('dist/'));
});

gulp.task('build', function() {
  gulp.run('dist');
});

gulp.task('default', function () {
  gulp.run('build');

  gulp.watch('src/**/*.coffee', function (event) {
    gulp.run('build');
  });
});
