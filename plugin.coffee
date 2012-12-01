
fs =  require 'fs'
path = require 'path'
hogan = require 'hogan'
_ = require 'underscore'
minify = require('html-minifier').minify
Kelvin = require './kelvin'
OUTPUT = './build'

module.exports = (wintersmith, callback) ->
  
  isProd = false
  kelvin = new Kelvin(isProd)
  
  class KelvinTemplate extends wintersmith.TemplatePlugin

    constructor: (@tpl) ->

    render: (locals, callback) ->
      _.extend locals, kelvin.parse(locals)
      try
        rendered = @tpl.render(locals)
        if isProd
          rendered = minify rendered, {
            collapseWhitespace: true
          }
        callback null, new Buffer rendered
      catch error
        callback error

  KelvinTemplate.fromFile = (filename, base, callback) ->
    fs.readFile path.join(base, filename), (error, contents) ->
      if error then callback error
      else
        try
          tpl = hogan.compile contents.toString()
          callback null, new KelvinTemplate tpl
        catch error
          callback error

  class KelvinStylesheets extends wintersmith.ContentPlugin

    constructor: (@_filename, @_base, @_source) ->
      @_hash = Kelvin.hashContents(@_source)
      return

    getFilename: ->
      Kelvin.formatFilename @_filename, @_hash, 'css'

    render: (locals, contents, templates, callback) ->
      require('less').render @_source, (error, out) ->
        if error
          callback error
        else
          callback null, new Buffer out

  KelvinStylesheets.fromFile = (filename, base, callback) ->
    fs.readFile path.join(base, filename), (error, buffer) ->
      if error
        callback error
      else
        callback null, new KelvinStylesheets filename, base, buffer.toString()

  class KelvinJavaScripts extends wintersmith.ContentPlugin

    constructor: (@_filename, @_base, @_source) ->
      @_hash = Kelvin.hashContents(@_source)
      return

    getFilename: ->
      Kelvin.formatFilename @_filename, @_hash, 'js'

    render: (locals, contents, templates, callback) ->
      callback null, new Buffer @_source

  KelvinJavaScripts.fromFile = (filename, base, callback) ->
    fs.readFile path.join(base, filename), (error, buffer) ->
      if error
        callback error
      else
        callback null, new KelvinJavaScripts filename, base, buffer.toString()

  class KelvinJavaScriptTemplates extends wintersmith.ContentPlugin

    constructor: (@_filename, @_base, @_source) ->
      @_hash = Kelvin.hashContents(@_source)
      return

    getFilename: ->
      Kelvin.formatFilename @_filename, @_hash, 'js'

    render: (locals, contents, templates, callback) ->
      callback null, new Buffer 'JST[\'' + Kelvin.templateNamespace(@_filename) + '\'] = new Hogan.Template(' + require('hogan').compile(@_source, { asString: true }) + ');'

  KelvinJavaScriptTemplates.fromFile = (filename, base, callback) ->
    fs.readFile path.join(base, filename), (error, buffer) ->
      if error
        callback error
      else
        callback null, new KelvinJavaScriptTemplates filename, base, buffer.toString()

  wintersmith.registerTemplatePlugin '**/*.*mustache', KelvinTemplate
  wintersmith.registerContentPlugin 'css', '**/*.less', KelvinStylesheets
  wintersmith.registerContentPlugin 'js', '**/*.js', KelvinJavaScripts
  wintersmith.registerContentPlugin 'jst', '**/*.mustache', KelvinJavaScriptTemplates
  callback()