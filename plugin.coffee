
less = require 'less'
path = require 'path'
async = require 'async'
fs = require 'fs'

module.exports = (wintersmith, callback) ->
  
  class KelvinPlugin extends wintersmith.ContentPlugin

    constructor: (@_filename, @_base) ->

    getFilename: ->
      @_filename

    render: (locals, contents, templates, callback) ->
      console.log(locals);

  KelvinPlugin.fromFile = (filename, base, callback) ->
    callback null, new KelvinPlugin filename

  wintersmith.registerContentPlugin 'assets', 'index.json', KelvinPlugin
  callback()