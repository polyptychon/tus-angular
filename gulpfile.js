var gulp = require('gulp'),
    jade = require('gulp-jade'),
    browserify = require('gulp-browserify'),
    uglify = require('gulp-uglify'),
    sass = require('gulp-sass'),
    prefix = require('gulp-autoprefixer'),
    csso = require('gulp-csso'),
    rename = require('gulp-rename'),

    webserver = require('gulp-webserver'),

    runSequence = require('run-sequence'),
    livereload = require('gulp-livereload'),
    gulpif = require('gulp-if');

var DEVELOPMENT = 'development',
    PRODUCTION = 'production',
    BUILD = "builds/",
    LIB = "lib/",
    ASSETS = "/assets",
    MOCKUPS = "_mockups",
    SRC = "_src";

var env = process.env.NODE_ENV || DEVELOPMENT;
if (env!==DEVELOPMENT) env = PRODUCTION;

function getOutputDir() {
  return BUILD+env;
}

gulp.task('jade', function() {
  var config = {
    locals: ""
  };

  if (env === DEVELOPMENT) {
    config.pretty = true;
  }
  return gulp.src(SRC+"/templates/**/index.jade")
    .pipe(jade(config))
    .pipe(gulp.dest(getOutputDir()));
});
gulp.task('js', function() {
  return gulp.src(SRC+'/js/main.js')
    .pipe(browserify({ debug: env === DEVELOPMENT }))
    .pipe(gulpif(env === PRODUCTION, uglify()))
    .pipe(gulp.dest(getOutputDir()+ASSETS+'/js'));
});

gulp.task('coffee', function() {
  gulp.src(SRC+'/coffee/app.coffee', { read: false })
    .pipe(browserify({
      debug: env === DEVELOPMENT,
      transform: ['coffeeify'],
      extensions: ['.coffee']
    }))
    .pipe(gulpif(env === PRODUCTION, uglify()))
    .pipe(rename(ASSETS+'/js/app.js'))
    .pipe(gulp.dest(getOutputDir()))
});

gulp.task('lib', function() {
  gulp.src(SRC+'/coffee/Tus.coffee', { read: false })
    .pipe(browserify({
      debug: false,
      transform: ['coffeeify'],
      extensions: ['.coffee'],
      ignore: ['jquery']
    }))
    .pipe(rename('app.js'))
    .pipe(gulp.dest(LIB))
});

gulp.task('fonts', function() {
  return gulp.src('bower_components/bootstrap-sass/fonts/*')
    .pipe(gulp.dest(getOutputDir()+ASSETS+'/fonts'));
});
gulp.task('sass', function() {
  var config = {};

  if (env === DEVELOPMENT) {
    //config.sourceComments = 'map';
  } else if (env === PRODUCTION) {
    config.outputStyle = 'compressed';
  }

  return gulp.src(SRC+'/sass/main.scss')
    .pipe(sass(config))
    .pipe(prefix("last 2 versions", "> 1%", "ie 8", "ie 7", { cascade: true }))
    .pipe(gulpif(env === PRODUCTION, csso()))
    .pipe(gulp.dest(getOutputDir()+ASSETS+'/css'));
});
gulp.task('watch', function() {
  gulp.watch(SRC+'/**/*.jade', ['jade']);
  gulp.watch(SRC+'/**/*.coffee', ['coffee']);
  gulp.watch(SRC+'/**/*.scss', ['sass']);
  var server = livereload();
  gulp.watch(BUILD+'**').on('change', function(file) {
    server.changed(file.path);
  });
});
gulp.task('connect', function() {
  useServer = true;
  gulp.src(BUILD+env)
    .pipe(webserver({
      //host: '0.0.0.0',
      livereload: true,
      directoryListing: true,
      open: "index.html"
    }));
});
gulp.task('default', ['fonts', 'coffee', 'jade', 'sass']);
gulp.task('live', ['coffee', 'jade', 'sass', 'watch']);

gulp.task('production', function() {
  env = PRODUCTION;
  runSequence(['fonts','coffee','jade','sass']);
});
