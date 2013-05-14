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
    it 'should require a string as its first parameter', ->
      instance.traverse.bind(undefined, undefined).should.throw Error
      instance.traverse.bind(undefined, 'index.js').should.not.throw Error

    describe 'parameters', ->

      it 'should throw if the first param is not a string', ->
        instance.traverse.bind(undefined, undefined).should.throw Error
        instance.traverse.bind(undefined, 'index.js').should.not.throw Error
      it 'should execute the callback with an error if the first param is not a string', ->
        spy = sinon.spy()
        instance.traverse(undefined, spy)
        spy.should.have.been.called
        spy.lastCall.args[0].should.be.instanceof Error
      it 'should throw if the second param is defined and not a function', ->
        instance.traverse.bind(undefined, 'index.js').should.not.throw Error
        instance.traverse.bind(undefined, 'index.js', -> ).should.not.throw Error
        instance.traverse.bind(undefined, undefined, -> ).should.not.throw Error
        instance.traverse.bind(undefined, undefined).should.throw Error
        instance.traverse.bind(undefined, undefined, undefined).should.throw Error

  describe "Traversing the file system", ->

    it 'should execute the callback with an error if it does not exist', (done)->
      fs2jsonModule().traverse 'spec/fixtures/null', ->
        arguments[0].should.be.instanceof Error
        done()

    describe 'Using a file as root', ->

      it 'should pass the stats of the file to the callback', (done)->
        instance = fs2jsonModule()
        instance.traverse 'spec/fixtures/file_as_root', (err, data)->
          data.should.be.a 'object'
          data.should.contain.keys ['name', 'relativePath', 'fullPath', 'size', 'type']
          data.name.should.equal 'file_as_root'
          data.relativePath.should.equal 'spec/fixtures/file_as_root'
          data.fullPath.should.equal require('path').resolve('spec/fixtures/file_as_root')
          data.size.should.equal 0
          data.type.should.equal 'file'
          done()

      it 'should not have a children property', (done)->
        instance = fs2jsonModule()
        instance.traverse 'spec/fixtures/file_as_root', (err, data)->
          data.should.not.include.keys ['children']
          done()

    describe 'Using a directory as root', ->

      it 'should pass the stats of the dir to the callback', (done)->
        instance = fs2jsonModule()
        instance.traverse 'spec/fixtures/empty', (err, data)->
          data.should.be.a 'object'
          data.should.contain.keys ['name', 'relativePath', 'fullPath', 'size', 'type']
          data.name.should.equal 'empty'
          data.relativePath.should.equal 'spec/fixtures/empty'
          data.fullPath.should.equal require('path').resolve('spec/fixtures/empty')
          data.size.should.equal 68
          data.type.should.equal 'directory'
          done()

      describe 'The directory is empty', ->

        it 'should have an empty array as its children property', (done)->
          instance = fs2jsonModule()
          instance.traverse 'spec/fixtures/empty', (err, data)->
            data.children.should.be.a 'array'
            data.children.length.should.equal 0
            done()

      describe 'The directory contains elements', ->
        it 'should have a children property containing an array', (done)->
          instance = fs2jsonModule()
          instance.traverse 'spec/fixtures/single_file', (err, data)->
            data.children.should.be.a 'array'
            data.children.length.should.equal 1
            done()



