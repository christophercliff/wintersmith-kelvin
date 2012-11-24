
glob = require 'glob'
path = require 'path'
_ = require 'underscore'
crypto = require 'crypto'

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
      return @assets
    @assets = {}
    for type, obj of @expandAssetGlobs locals.assets
      for pkg, arr of obj
        if _.isArray arr
          unless @assets[type]
            @assets[type] = {}
          @assets[type][pkg] = @processPackage arr, type
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

  processPackage: (files, type) ->
    output = '\n'
    for file in files
      output += link.join(' ')
    output

module.exports = Kelvin