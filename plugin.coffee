
less = require 'less'
path = require 'path'
async = require 'async'
fs = require 'fs'
nap = require 'nap'

module.exports = (wintersmith, callback) ->
  
  preprocessPackage = (type, assets) ->
    for k,v of assets
      console.log type, v._filename
    return
  
  class KelvinPlugin extends wintersmith.ContentPlugin

    constructor: (@_filename, @_base) ->

    getFilename: ->
      @_filename

    render: (locals, contents, templates, callback) ->
      if !contents.assets
        return;
      if contents.assets.css
        preprocessPackage 'css', contents.assets.css
      return;

  KelvinPlugin.fromFile = (filename, base, callback) ->
    callback null, new KelvinPlugin filename

  wintersmith.registerContentPlugin 'assets', 'index.json', KelvinPlugin
  callback()