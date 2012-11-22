
less = require 'less'
path = require 'path'
async = require 'async'
fs = require 'fs'
nap = require 'nap'
hogan = require 'hogan'
_ = require 'underscore'
minify = require('html-minifier').minify
glob = require 'glob'
Kelvin = require('./kelvin')

module.exports = (wintersmith, callback) ->
  
  isProd = false
  kelvin = new Kelvin(isProd)
  
  preprocessPackage = (type, package) ->
    for name, files of package
      for file in files
        console.log file
    return

  class KelvinTemplate extends wintersmith.TemplatePlugin

    constructor: (@tpl) ->

    render: (locals, callback) ->
      if (locals.assets)
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
          _.extend ctx, locals, parseAssets contents
          template.render ctx, callback
      ], callback
  
  class KelvinMarkdownPage extends wintersmith.defaultPlugins.MarkdownPage

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
          _.extend ctx, locals, parseAssets contents
          template.render ctx, callback
      ], callback
  
  parseAssets = (contents) ->
    config = contents['assets.json']['assets']['assets']
    unless config
      return
    config = expandAssetGlobs config
    assets = {}
    unless _.isEmpty(config.js)
      assets.css = {}
      for name, pkg of config.css
        assets.css[name] = parsePackage pkg, 'css'
    assets

  parsePackage = (pkg, type) ->
    console.log pkg, type
    {}

  expandAssetGlobs = (config) ->
    assets = { js: {}, css: {}, jst: {} }
    appDir = process.cwd().replace(/\\/g, '\/')
    appDir += '/contents/'
    for key, obj of config
      for pkg, patterns of config[key]
        matches = []
        for pattern in patterns
          fnd = glob.sync path.resolve("#{appDir}#{pattern}").replace(/\\/g, '\/')
          matches = matches.concat(fnd)
        matches = _.uniq _.flatten matches
        matches = (file.replace(appDir, '').replace(/^\//, '') for file in matches)
        assets[key][pkg] = matches
    assets

  #wintersmith.registerContentPlugin 'pages', '**/*.json', KelvinJsonPage
  #wintersmith.registerContentPlugin 'pages', '**/*.*(markdown|mkd|md)', KelvinMarkdownPage
  #wintersmith.registerContentPlugin 'assets', 'assets.json', KelvinAssets
  wintersmith.registerTemplatePlugin '**/*.*(mustache|hogan)', KelvinTemplate
  callback()