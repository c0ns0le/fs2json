sinon = require 'sinon'
chai = require 'chai'
q = require 'q'
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

describe "Traversing the file system", ->

  it 'should execute the callback with an error if the path does not exist', (done)->
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
        data.relativePath.should.equal ''
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
        data.relativePath.should.equal ''
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
          done()
      describe 'the children array', ->
        it 'should have the correct length', (done)->
          dfd1 = q.defer()
          dfd2 = q.defer()
          q.all([dfd1.promise,dfd2.promise]).spread -> done()
          instance = fs2jsonModule()
          instance.traverse 'spec/fixtures/single_file', (err, data)->
            data.children.length.should.equal 1
            dfd1.resolve()
          instance = fs2jsonModule()
          instance.traverse 'spec/fixtures/multiple_files', (err, data)->
            data.children.length.should.equal 2
            dfd2.resolve()
        it 'should describe the children elements', (done)->
          dfdParent = q.defer()
          dfdChild = q.defer()
          instance = fs2jsonModule()
          instance.traverse 'spec/fixtures/single_file', (err, data)->
            dfdParent.resolve data.children[0]
          instance.traverse 'spec/fixtures/single_file/file1', (err, data)->
            dfdChild.resolve data
          q.all([dfdParent.promise, dfdChild.promise]).spread (childFromParent, child)->
            childFromParent.relativePath.should.eql 'file1'
            child.relativePath.should.eql ''
            delete childFromParent.relativePath
            delete child.relativePath
            childFromParent.should.eql child
            done()

describe 'specify the depth (recursively proven)', ->
  describe 'depth 0', ->
    it 'should be the root of the search when a directory', (done)->
      instance = fs2jsonModule()
      instance.traverse {path: 'spec/fixtures', depth: 0}, (err, data)->
        data.children.length.should.equal 0
        done()
    it 'should be the root of the search when a file', (done)->
      instance = fs2jsonModule()
      instDfd = q.defer()
      instanceCheck = fs2jsonModule()
      instChkDfd = q.defer()

      instance.traverse {path: 'index.js', depth: 0}, (err, data)->
        instDfd.resolve(data)
      instanceCheck.traverse 'index.js', (err, data)->
        instChkDfd.resolve(data)

      q.all([instDfd.promise, instChkDfd.promise]).spread (inst, chk)->
        inst.should.eql chk
        done()


  describe 'depth 1', ->
    it 'should be empty with a file as root', (done)->
      instance = fs2jsonModule()
      instance.traverse {path: 'index.js', depth: 1}, (err, data)->
        data.should.eql {}
        done()
    it 'should be the direct children with a directory as root and children are terminal in the filesystem', (done)->
      instance = fs2jsonModule()
      instance.traverse {path: 'spec/fixtures/multiple_files', depth: 1}, (err, data)->
        data.children.length.should.equal 2
        done()
    it 'should be the direct children with a directory as root even when there are nodes deeper', (done)->
      instance = fs2jsonModule()
      instance.traverse {path: 'spec/fixtures', depth: 1}, (err, data)->
        data.children.length.should.equal 6
        done()


  describe 'depth n',->
    it 'should be empty of children of lesser depth', (done)->
      instance = fs2jsonModule()
      instance.traverse {path: 'spec/fixtures/multiple_files', depth: 2}, (err, data)->
        data.should.not.contain.keys['children']
        done()
    xit 'should be empty of children of lesser depth', (done)->
      instance = fs2jsonModule()
      instance.traverse {path: 'spec', depth: 2}, (err, data)->
        done()





