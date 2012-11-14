
less = require 'less'
path = require 'path'
async = require 'async'
fs = require 'fs'
nap = require 'nap'
hogan = require 'hogan'

module.exports = (wintersmith, callback) ->

  preprocessPackage = (type, package) ->
    for name, files of package
      for file in files
        console.log file
    return

  class KelvinTemplate extends wintersmith.TemplatePlugin

    constructor: (@tpl) ->

    render: (locals, callback) ->
      try
        callback null, new Buffer @tpl.render(locals)
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

  class KelvinContent extends wintersmith.ContentPlugin

    constructor: (@_filename, @_base, @assets) ->

    getFilename: ->
      @_filename

    render: (locals, contents, templates, callback) ->
      if !@assets
        return;
      if @assets.css
        preprocessPackage 'css', @assets.css
      return;

  KelvinContent.fromFile = (filename, base, callback) ->
    fs.readFile path.join(base, filename), (error, buffer) ->
      if error
        callback erro
      else
        callback null, new KelvinContent filename, base, JSON.parse(buffer.toString())

  wintersmith.registerTemplatePlugin '**/*.*(mustache|hogan)', KelvinTemplate
  wintersmith.registerContentPlugin 'assets', 'assets.json', KelvinContent
  callback()