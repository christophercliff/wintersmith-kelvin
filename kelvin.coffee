
glob = require 'glob'
path = require 'path'
_ = require 'underscore'
crypto = require 'crypto'
nap = require 'nap'
fs = require 'fs'

linkAttrs = {
  'href': '',
  'rel': 'stylesheet',
  'type': 'text/css'
}
link = ['<link', '/>\n']
scriptAttrs = {
  'src': ''
}
script = ['<script', '></script>']

class Kelvin

  constructor: (@isProd) ->

  parse: (locals) ->
    if (@assets)
      return {
        assets: @assets
      }
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
      contents = fs.readFileSync(path.resolve process.cwd() + '/contents/' + file).toString()
      ext = path.extname file
      if nap.preprocessors[ext]
        contents = nap.preprocessors[ext] contents, file
      filename = "/#{file}.#{hashContents(contents)}.css"
      writeFile filename, contents
      output += "<link href=\"#{filename}\" rel=\"stylesheet\" />\n"
    output

hashContents = (contents) ->
  md5 = crypto.createHash('md5')
  md5.update contents
  md5.digest('hex')

writeFile = (filename, contents) =>
  file = process.cwd() + '/build/' + filename
  dir = path.dirname file
  mkdirp.sync dir, '0755' unless path.existsSync dir
  fs.writeFileSync file, contents ? ''

module.exports = Kelvin