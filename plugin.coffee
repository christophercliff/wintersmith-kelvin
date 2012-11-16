
less = require 'less'
path = require 'path'
async = require 'async'
fs = require 'fs'
nap = require 'nap'
hogan = require 'hogan'
_ = require 'underscore'

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

  class KelvinAssets extends wintersmith.ContentPlugin

    constructor: (@_filename, @_base, @assets) ->

    getFilename: ->
      @_filename

    render: (locals, contents, templates, callback) ->
      if !@assets
        return;
      if @assets.css
        preprocessPackage 'css', @assets.css
      return;

  KelvinAssets.fromFile = (filename, base, callback) ->
    fs.readFile path.join(base, filename), (error, buffer) ->
      if error
        callback error
      else
        callback null, new KelvinAssets filename, base, JSON.parse(buffer.toString())

  class KelvinJsonPage extends wintersmith.defaultPlugins.JsonPage
    
    render: (locals, contents, templates, callback) ->
      if @template == 'none'
        # dont render
        return callback null, null

      async.waterfall [
        (callback) =>
          template = templates[@template]
          if not template?
            callback new Error "page '#{ @filename }' specifies unknown template '#{ @template }'"
          else
            callback null, template
        (template, callback) =>
          ctx =
            page: @
            contents: contents
            _: _
            moment: require 'moment'
          _.extend ctx, locals, assets
          template.render ctx, callback
      ], callback

  assets =
    css:
      all: '<link rel="text/css" href="test.css" />'
    js:
      all: '<script src="test.js"></script>'

  wintersmith.registerContentPlugin 'pages', '**/*.json', KelvinJsonPage
  #wintersmith.registerContentPlugin 'pages', '**/*.*(markdown|mkd|md)', KelvinMarkdownPage
  wintersmith.registerContentPlugin 'assets', 'assets.json', KelvinAssets
  wintersmith.registerTemplatePlugin '**/*.*(mustache|hogan)', KelvinTemplate
  callback()