
glob = require 'glob'
path = require 'path'
_ = require 'underscore'
crypto = require 'crypto'
nap = require 'nap'
less = require 'less'
fs = require 'fs'
uglifyjs = require 'uglify-js'
sqwish = require 'sqwish'
async = require 'async'
hoganTemplate = fs.readFileSync(__dirname + '/hogan.template.js', 'utf8')

class Kelvin

  constructor: (@isProd) ->

  parse: (locals, contentsDir) ->
    @assets = {}
    @contentsDir = contentsDir
    @cdn = locals.cdn
    for type, obj of @expandAssetGlobs locals.assets
      for name, arr of obj
        if _.isArray arr
          unless @assets[type]
            @assets[type] = {}
          @assets[type][name] = @processPackage name, arr, type
    return {
      assets: @assets
    }

  expandAssetGlobs: (assets) ->
    expandedAssets = { js: {}, css: {}, jst: {} }
    for key, obj of assets
      for pkg, patterns of assets[key]
        matches = []
        for pattern in patterns
          fnd = glob.sync path.resolve("#{@contentsDir}/#{pattern}").replace(/\\/g, '\/')
          matches = matches.concat(fnd)
        matches = _.uniq _.flatten matches
        expandedAssets[key][pkg] = matches
    expandedAssets

  processPackage: (name, files, type) ->
    output = '\n'
    if @isProd
      source = @transform files, type
      hash = Kelvin.hashContents source
      filename = ''
      formattedFilename = '/assets/' + type + '/' + Kelvin.formatFilename name, hash, type
      writeFilename = @contentsDir.replace(/contents$/, 'build') + formattedFilename
      writeFile(writeFilename, source)
      if @cdn
        filename += '//' + @cdn
      filename += formattedFilename
      output += Kelvin.formatTag(filename, type) + '\n'
    else
      if type == 'jst'
        output += hoganPrefix()
      for file in files
        source = fs.readFileSync(file, 'utf8')
        hash = Kelvin.hashContents source
        filename = Kelvin.formatFilename file, hash, type
        output += Kelvin.formatTag(filename, type) + '\n'
    output
  
  transform: (files, type) ->
    arr = []
    if type is 'jst'
      arr.push hoganTemplate
    for filename in files
      ext = path.extname filename
      contents = fs.readFileSync filename, 'utf8'
      if nap.preprocessors[ext]
        arr.push nap.preprocessors[ext](contents, filename)
      else if nap.templateParsers[ext]
        arr.push Kelvin.templateDefinition(contents, filename.replace(@contentsDir, ''))
      else
        arr.push contents
    source = ''
    if type is 'js' or type is 'jst'
      source = uglify(arr.join(''))
    else if type is 'css'
      source = sqwish.minify(arr.join(''))
    source

Kelvin.hashContents = (source) ->
  md5 = crypto.createHash('md5')
  md5.update source
  md5.digest('hex')

Kelvin.formatFilename = (filename, hash, type) ->
  ext = if type == 'jst' then 'js' else type
  filename + '-' + hash + '.' + ext
  
Kelvin.formatTag = (filename, type) ->
  switch type
    when 'css'
      '<link href="' + filename + '" rel="stylesheet" />'
    when 'js'
      '<script src="' + filename + '"></script>'
    when 'jst'
      '<script src="' + filename + '"></script>'

Kelvin.templateDefinition = (source, filename) ->
  'JST[\'' + Kelvin.templateNamespace(filename) + '\'] = new Hogan.Template(' + require('hogan').compile(source, { asString: true }) + ');'

Kelvin.templateNamespace = (filename) ->
  ns = filename.replace /^\/?assets\/jst\//, ''
  ns.replace /.mustache$/, ''

writeFile = (filename, contents) ->
  dir = path.dirname filename
  mkdirp.sync dir, '0755' unless path.existsSync dir
  fs.writeFileSync filename, contents ? ''

hoganPrefix = () ->
  '<script>' + uglify(hoganTemplate)  + '</script>\n'

uglify = (str) ->
  jsp = uglifyjs.parser
  pro = uglifyjs.uglify
  ast = jsp.parse str
  ast = pro.ast_mangle(ast)
  ast = pro.ast_squeeze(ast)
  pro.gen_code(ast)

module.exports = Kelvin