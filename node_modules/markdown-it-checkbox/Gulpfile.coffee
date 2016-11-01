del     = require 'del'
gulp    = require 'gulp'
coffee  = require 'gulp-coffee'
gutil   = require 'gulp-util'
bump    = require 'gulp-bump'
git     = require 'gulp-git'
filter  = require 'gulp-filter'
tag     = require 'gulp-tag-version'
{spawn} = require 'child_process'

inc = (importance) ->
  # get all the files to bump version in
  return gulp.src ['./package.json', './bower.json']
    # bump the version number in those files
    .pipe bump({type: importance})
    # save it back to filesystem
    .pipe gulp.dest('./')
    # commit the changed version number
    .pipe git.commit('bumps package version')
    # read only one file to get the version number
    .pipe filter('package.json')
    # **tag it in the repository**
    .pipe tag()

# compile `index.coffee`
gulp.task 'coffee', ->
  gulp.src('index.coffee')
    .pipe(coffee bare: true)
    .pipe(gulp.dest './')

# remove `index.js` and `coverage` dir
gulp.task 'clean', (cb) ->
  del ['dist', 'coverage', 'temp'], cb

# run tests
gulp.task 'test', ['coffee'], ->
  spawn 'npm', ['test'], stdio: 'inherit'

# run `md` for testing purposes
gulp.task 'md', ->
  markdownIt = require './index.coffee'
  gulp.src('./{,test/,test/fixtures/}*.md')
    .pipe(markdownIt())
    .pipe(gulp.dest './temp')

# start workflow
gulp.task 'default', ['coffee'], ->
  gulp.watch ['./{,test/,test/fixtures/}*.coffee'], ['test']

gulp.task 'patch', ->
  inc 'patch'

gulp.task 'feature', ->
  inc 'minor'

gulp.task 'release', ->
  inc 'major'
