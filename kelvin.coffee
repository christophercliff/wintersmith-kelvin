
glob = require 'glob'
path = require 'path'
_ = require 'underscore'
crypto = require 'crypto'
nap = require 'nap'
less = require 'less'
fs = require 'fs'

class Kelvin

  constructor: (@isProd) ->

  parse: (locals) ->
    #if (@assets)
    #  return {
    #    assets: @assets
    #  }
    @assets = {}
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
    appDir = process.cwd().replace(/\\/g, '\/')
    appDir += '/contents/'
    for key, obj of assets
      for pkg, patterns of assets[key]
        matches = []
        for pattern in patterns
          fnd = glob.sync path.resolve("#{appDir}#{pattern}").replace(/\\/g, '\/')
          matches = matches.concat(fnd)
        matches = _.uniq _.flatten matches
        matches = (file.replace(appDir, '').replace(/^\//, '') for file in matches)
        expandedAssets[key][pkg] = matches
    expandedAssets

  processPackage: (name, files, type) ->
    output = '\n'
    for file in files
      source = fs.readFileSync(path.resolve process.cwd() + '/contents/' + file).toString()
      hash = Kelvin.hashContents source
      filename = Kelvin.formatFilename file, hash, type
      ext = path.extname file
      if nap.preprocessors[ext]
        source = nap.preprocessors[ext] source, file
      #writeFile filename, contents
      output += Kelvin.formatTag(filename, type) + '\n'
    output

Kelvin.hashContents = (source) ->
  md5 = crypto.createHash('md5')
  md5.update source
  md5.digest('hex')

Kelvin.formatFilename = (filename, hash, type) ->
  ext = if type == 'jst' then 'js' else type
  '/' + filename + '-' + hash + '.' + ext
  
Kelvin.formatTag = (filename, type) ->
  switch type
    when 'css'
      '<link href="' + filename + '" rel="stylesheet" />'
    when 'js'
      '<script src="' + filename + '"></script>'
    when 'jst'
      '<script src="' + filename + '"></script>'

Kelvin.templateNamespace = (filename) ->
  ns = filename.replace /^assets\/jst\//, ''
  ns.replace /.mustache$/, ''

writeFile = (filename, contents) ->
  file = process.cwd() + '/build/' + filename
  dir = path.dirname file
  mkdirp.sync dir, '0755' unless path.existsSync dir
  fs.writeFileSync file, contents ? ''

module.exports = Kelvin