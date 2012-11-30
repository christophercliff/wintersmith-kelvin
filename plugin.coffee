
fs =  require 'fs'
path = require 'path'
hogan = require 'hogan'
_ = require 'underscore'
minify = require('html-minifier').minify
Kelvin = require './kelvin'

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

  class KelvinStyles extends wintersmith.ContentPlugin

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

  KelvinStyles.fromFile = (filename, base, callback) ->
    fs.readFile path.join(base, filename), (error, buffer) ->
      if error
        callback error
      else
        callback null, new KelvinStyles filename, base, buffer.toString()

  wintersmith.registerTemplatePlugin '**/*.*(mustache|hogan)', KelvinTemplate
  wintersmith.registerContentPlugin 'styles', '**/*.less', KelvinStyles
  callback()