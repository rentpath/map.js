'use strict';

var gulp = require('gulp');
var coffee = require('gulp-coffee')
var gutil = require('gulp-util')
var sourcemaps = require('gulp-sourcemaps')
var del = require('del');

gulp.task('dist', function() {
  gulp.src([ 'src/**/*.coffee' ])
  .pipe(coffee({bare: true}).on('error', gutil.log))
  .pipe(gulp.dest('./'));
});

gulp.task('coffee', function() {
  gulp.src('src/**/*.coffee')
    .pipe(coffee({header: true}).on('error', gutil.log))
    .pipe(gulp.dest('./'));
});

gulp.task('build', function() {
  gulp.run('coffee');
});

gulp.task('default', function () {
  gulp.run('build');

  gulp.watch('src/**/*.coffee', function (event) {
    gulp.run('coffee');
    gulp.run('dist');
  });
});
