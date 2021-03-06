sinon = require 'sinon'
chai = require 'chai'
q = require 'q'
chai.use require('sinon-chai')
chai.should()

helpers = require './helpers'

fs2jsonModule = require '../index'

after ->
  helpers.fake_fs.clean()

describe 'the module', ->
  it 'should be a function', ->
    fs2jsonModule.should.be.a 'function'
  it 'should return an object', ->
    fs2jsonModule().should.be.an 'object'

xdescribe 'public API', ->

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

      describe 'first is a string', ->
        it 'should accept a string as a first parameter', ->
          instance.traverse.bind(undefined, 'index.js').should.not.throw Error
        it 'should accept an object as second parameter', ->
          instance.traverse.bind(undefined, 'index.js', {}).should.not.throw Error
        it 'should accept a function as second parameter', (done)->
          instance.traverse.bind(undefined, 'index.js', -> done()).should.not.throw Error
        it 'should accept an object as second and a function as third parameter', (done)->
          instance.traverse.bind(undefined, 'index.js', {}, -> done()).should.not.throw Error
      describe 'first is an object', ->
        it 'should accept an object with a path property as a first parameter', ->
          instance.traverse.bind(undefined, {}).should.throw Error
          instance.traverse.bind(undefined, {path: 'index.js'}).should.not.throw Error
        it 'should accept a function as the second', (done)->
          instance.traverse.bind(undefined, {path: 'index.js'}, -> done()).should.not.throw Error

      it 'should execute the callback with an error if the first param is not a string', (done)->
        instance.traverse undefined, (arg)-> 
          done()
          arg.should.be.instanceof Error
      it 'should throw if the second param is defined and not a function', ->
        instance.traverse.bind(undefined, 'index.js').should.not.throw Error
        instance.traverse.bind(undefined, 'index.js', -> ).should.not.throw Error
        instance.traverse.bind(undefined, undefined, -> ).should.not.throw Error
        instance.traverse.bind(undefined, undefined).should.throw Error
        instance.traverse.bind(undefined, undefined, undefined).should.throw Error

xdescribe "Traversing the file system", ->

  it 'should execute the callback with an error if the path does not exist', (done)->
    fs2jsonModule().traverse 'spec/fixtures/null', ->
      arguments[0].should.be.instanceof Error
      done()

  describe 'Using a file as root', ->

    it 'should pass the stats of the file to the callback', (done)->
      instance = fs2jsonModule()
      path = helpers.fake_fs 'file_as_root'
      instance.traverse path, (err, data)->
        data.should.be.a 'object'
        data.should.contain.keys ['name', 'relativePath', 'fullPath', 'size', 'type']
        data.name.should.equal 'file_as_root'
        data.relativePath.should.equal ''
        data.fullPath.should.equal require('path').resolve path
        data.size.should.equal 0
        data.type.should.equal 'file'
        done()

    it 'should not have a children property', (done)->
      instance = fs2jsonModule()
      path = helpers.fake_fs 'file_as_root'
      instance.traverse path, (err, data)->
        data.should.not.include.keys ['children']
        done()

  describe 'Using a directory as root', ->

    it 'should pass the stats of the dir to the callback', (done)->
      instance = fs2jsonModule()
      path = helpers.fake_fs 'empty_dir'
      instance.traverse path, (err, data)->
        data.should.be.a 'object'
        data.should.contain.keys ['name', 'relativePath', 'fullPath', 'size', 'type']
        data.name.should.equal 'empty'
        data.relativePath.should.equal ''
        data.fullPath.should.equal require('path').resolve path
        data.type.should.equal 'directory'
        done()

    describe 'The directory is empty', ->

      it 'should have an empty array as its children property', (done)->
        instance = fs2jsonModule()
        path = helpers.fake_fs 'empty_dir'
        instance.traverse path, (err, data)->
          data.children.should.be.a 'array'
          data.children.length.should.equal 0
          done()

    describe 'The directory contains elements', ->
      it 'should have a children property containing an array', (done)->
        instance = fs2jsonModule()
        path = helpers.fake_fs 'dir_one_file'
        instance.traverse path, (err, data)->
          data.children.should.be.a 'array'
          done()
      describe 'the children array', ->
        it 'should have the correct length', (done)->
          dfd1 = q.defer()
          dfd2 = q.defer()
          q.all([dfd1.promise,dfd2.promise]).spread -> done()
          instance = fs2jsonModule()
          path = helpers.fake_fs 'dir_one_file'
          instance.traverse path, (err, data)->
            data.children.length.should.equal 1
            dfd1.resolve()
          instance = fs2jsonModule()
          path = helpers.fake_fs 'dir_two_files'
          instance.traverse path, (err, data)->
            data.children.length.should.equal 2
            dfd2.resolve()
        it 'should describe the children elements', (done)->
          dfdParent = q.defer()
          dfdChild = q.defer()
          instance = fs2jsonModule()
          path = helpers.fake_fs 'dir_one_file'
          instance.traverse path, (err, data)->
            dfdParent.resolve data.children[0]
          instance.traverse ([path, 'file'].join '/'), (err, data)->
            dfdChild.resolve data
          q.all([dfdParent.promise, dfdChild.promise]).spread (childFromParent, child)->
            childFromParent.relativePath.should.eql 'file'
            child.relativePath.should.eql ''
            delete childFromParent.relativePath
            delete child.relativePath
            childFromParent.should.eql child
            done()






