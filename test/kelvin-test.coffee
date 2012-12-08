
should = require 'should'
Kelvin = require '../lib/kelvin'

describe 'kelvin', ->
  
  describe 'constructor', ->
    
    it 'sets the properties', ->
      kelvin = new Kelvin true, '/contents', '/build', 'my.cdn.com'
      kelvin.isProd.should.exist
      kelvin.contentsDir.should.exist
      kelvin.buildDir.should.exist
      kelvin.cdn.should.exist

  describe 'parse', ->
    
    it 'should return an assets object', ->
      kelvin = new Kelvin false, '/contents', '/build'
      kelvin.parse({}).should.be.a('object').and.have.property('assets')
   
  describe 'format filename', ->

    it 'should format the filename', ->
      name = 'foo'
      hash = '123'
      Kelvin.formatFilename(name, hash, 'css').should.equal('foo-123.css')
      Kelvin.formatFilename(name, hash, 'js').should.equal('foo-123.js')
      Kelvin.formatFilename(name, hash, 'jst').should.equal('foo-123.js')
      
  describe 'format tag', ->

    it 'should format the tag', ->
      name = 'foo'
      Kelvin.formatTag(name, 'css').should.equal('<link href="foo" rel="stylesheet" />')
      Kelvin.formatTag(name, 'js').should.equal('<script src="foo"></script>')
      Kelvin.formatTag(name, 'jst').should.equal('<script src="foo"></script>')
      
  describe 'template namespace', ->

    it 'should create an appropriate namespace for JavaScript templates', ->
      Kelvin.templateNamespace('/assets/jst/a/b/c.mustache').should.equal('a/b/c')