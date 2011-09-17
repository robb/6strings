sys    = require 'sys'
util   = require 'util'
fs     = require 'fs'
{exec} = require 'child_process'

buildFiles = [
  'Constants',
  'Filter',
  'Lowpass',
  'ThreeBandEqualizer',
  'Synthesizer',
  'Main'
]

libFiles = [
  'jquery-1.6.3.min'
]

createDirs = ->
  dirs = [
    'bin',
    'bin/js',
    'bin/css',
    'bin/img'
  ]

  for dir in dirs
    try
      fs.mkdirSync "#{__dirname}/#{dir}", 0755
    catch err

addPadding = (string, padding, paddingString = ' ') ->
  string = paddingString + string while (string.length < padding)
  string

logCoffeeScriptError = (err, input) ->
  util.log err

  # Parse error message
  if lineNumber = parseInt err.toString().match(/error on line ([0-9]+)/)[1]
    lines = input.split('\n')
    console.log ''
    for offset in [-6..3]
      console.log addPadding(lineNumber + offset, 4) + ' ' +
                  lines[lineNumber + offset]

copyImages = ->
  exec 'cp src/img/* bin/img/'

compileHaml = ->
  exec 'haml src/index.haml bin/index.html', (err) ->
    util.log err if err?

compileSass = ->
  exec 'sass src/css/application.sass bin/css/application.css'

compileCoffeeScript = (debug = no, minify = no) ->
  coffee = require("coffee-script").compile
  uglify = require("uglify-js") if minify

  read = (filename) ->
    fs.readFileSync filename, "utf-8"

  output = ""

  libraries = for libFile in libFiles
    read "#{__dirname}/vendor/#{libFile}.js"
  output += libraries.join('\n\n')

  if debug
    output += "DEBUG = true;"
  else
    output += "DEBUG = false;"

  inputFiles = for buildFile in buildFiles
    read "#{__dirname}/src/coffee/#{buildFile}.coffee"

  try
    input = inputFiles.join('\n\n')
    output += coffee input
  catch err
    logCoffeeScriptError err, input

  output = uglify output if minify

  fs.writeFileSync "#{__dirname}/bin/js/application.js", output

task 'build', ->
  createDirs()
  copyImages()
  compileHaml()
  compileSass()
  compileCoffeeScript yes, no

task 'minify', ->
  createDirs()
  compileHaml()
  compileSass()
  compileCoffeeScript no, yes

task 'watch', ->
  createDirs()

  for buildFile in buildFiles then do (buildFile) ->
    file = "#{__dirname}/src/coffee/#{buildFile}.coffee"

    fs.watchFile file, (curr, prev) ->
      if +curr.mtime isnt +prev.mtime
        util.log "Saw change in #{file}"
        compileCoffeeScript yes, no

  fs.watchFile "#{__dirname}/src/index.haml", (curr, prev) ->
    if +curr.mtime isnt +prev.mtime
      util.log "Saw change in index.html"
      compileHaml()

  fs.readdir "#{__dirname}/src/css", (err, files) ->
    for file in files then do (file) ->
      fs.watchFile "#{__dirname}/src/css/#{file}", (curr, prev) ->
        if +curr.mtime isnt +prev.mtime
          util.log "Saw change in #{file}"
          compileSass()
