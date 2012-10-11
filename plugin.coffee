
less = require 'less'
path = require 'path'
async = require 'async'
fs = require 'fs'

module.exports = (wintersmith, callback) ->

  class LessPlugin extends wintersmith.ContentPlugin

    constructor: (@_filename, @_base, @_source) ->

    getFilename: ->
      @_filename.replace /less$/, 'css'

    render: (locals, contents, templates, callback) ->
      options =
        filename: @_filename
        paths: [path.dirname(path.join(@_base, @_filename))]
      # less throws errors all over the place...
      async.waterfall [
        (callback) ->
          try
            parser = new less.Parser options
            callback null, parser
          catch error
            callback error
        (parser, callback) =>
          try
            parser.parse @_source, callback
          catch error
            callback error
        (root, callback) ->
          try
            result = root.toCSS options
            callback null, new Buffer result
          catch error
            callback error
      ], callback

  LessPlugin.fromFile = (filename, base, callback) ->
    fs.readFile path.join(base, filename), (error, buffer) ->
      if error
        callback error
      else
        callback null, new LessPlugin filename, base, buffer.toString()

  wintersmith.registerContentPlugin 'styles', '**/*.less', LessPlugin
  callback()
