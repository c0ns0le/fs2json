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
    it 'should require a path as its first parameter', ->
      instance.traverse.bind(undefined, undefined).should.throw Error
    it 'should return an object literal', ->
      instance.traverse('path/to/false').should.be.a 'object'

  
    describe 'parameters', ->

      it 'should throw if the first param is not a string', ->
        instance.traverse.bind(undefined, undefined).should.throw Error
        instance.traverse.bind(undefined, 'path/to/file').should.not.throw Error
      it 'should execute the callback with an error if the first param is not a string', ->
        spy = sinon.spy()
        instance.traverse('path/to/false', spy)
        spy.should.have.been.called
        #TODO Check parameters of spy
      it 'should throw if the second param is defined and not a function', ->
        instance.traverse.bind(undefined, 'path/to/file', -> ).should.not.throw Error
        instance.traverse.bind(undefined, 'path/to/file').should.not.throw Error
        instance.traverse.bind(undefined, undefined, -> ).should.not.throw Error
        instance.traverse.bind(undefined, undefined).should.throw Error
        instance.traverse.bind(undefined, undefined, undefined).should.throw Error

describe 'Non-directory root', ->

   it 'should execute the callback with an error if the path does not exits', ->
     spy = sinon.spy()
     instance = fs2jsonModule().traverse('../specs/fixtures/null', spy)
     spy.should.have.beenCalled

