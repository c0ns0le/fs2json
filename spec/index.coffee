sinon = require 'sinon'
chai = require 'chai'
chai.use require('sinon-chai')
chai.should()

fs2jsonModule = require '../index'

describe 'the module', ->
  it 'should be a function', ->
    fs2jsonModule.should.be.a 'function'
  it 'should return an object', ->
    fs2jsonModule().should.be.an 'object'

describe 'public API', ->
  instance = null
  beforeEach ->
    instance = fs2jsonModule()
  describe 'include method', ->
    it 'should be available', ->
      instance.should.include.keys 'include'
      instance.include.should.be.a 'function'
    it 'should return the base object to allow chaining', ->
      instance.include().should.eql instance
  describe 'describe method', ->
    it 'should be available', ->
      instance.should.include.keys 'describe'
      instance.describe.should.be.a 'function'
    it 'should return the base object to allow chaining', ->
      instance.describe().should.eql instance
  describe 'traverse method', ->
    it 'should be available', ->
      instance.should.include.keys 'traverse'
      instance.traverse.should.be.a 'function'
    describe 'parameters', ->
      it 'should throw if no path and no callback is given', ->
        instance.describe.bind(undefined, undefined).should.throw
      it 'should execute the callback with an error if the path is not a string', ->
        spy = sinon.spy()
        instance.describe(undefined, undefined, spy)
        spy.should.have.been.called
        #TODO Check parameters of spy
    it 'should require a path as its first parameter', ->
      instance.describe.bind(undefined, undefined).should.throw
    it 'should return an object literal', ->
      instance.describe().should.eql instance
  describe 'traverse method', ->

describe 'Non-directory root', ->
   it 'should throw if non-existent path', ->
