traverse = require '../lib/traverse'
sinon = require 'sinon'
helpers = require './helpers'
fixtures = require './fixtures/fs.json'
q = require 'q'

describe 'Traversing a non-existing path', ->
  it 'should emit an `error` event', (done)->
    em = traverse 'make_sure_to_never_add_such_a_folder_name_to_any_of_my_code_in_my_entire_life' #That most certainly does not exist!
    em.on 'error', ->
      done()

  # @TODO How to check that the event has NOT been raised, when the only other event is raised prior to it?
  #       Use timeouts ? Seems ugly...
  xit 'should not emit an `end` event', ()->
    dfd = q.defer()
    em = traverse 'qwertyuiopasdfghjklzxcvbnm' #That one either...
    em.on 'error', ->
      done()
    em.on 'end', ->
      throw 'should not have been called'

describe 'Traversing with a file as root', ->
  it 'should emit a `path` event', (done)->
    path = helpers.fake_fs 'file_as_root'
    em = traverse path
    em.on 'path', ->
      done()
  it 'should emit a `end` event', (done)->
    path = helpers.fake_fs 'file_as_root'
    em = traverse path
    em.on 'end', ->
      done()
  it 'should emit the `end` event after the `path` event', (done)->
    spy = sinon.spy()
    path = helpers.fake_fs 'file_as_root'
    em = traverse path
    em.on 'path', spy
    em.on 'end', ->
      spy.should.have.been.called
      done()

describe 'Traversing an empty dir', ->
  it 'should emit a `path` event', (done)->
    path = helpers.fake_fs 'empty_dir'
    em = traverse path
    em.on 'path', ->
      done()
  it 'should emit a `end` event', (done)->
    path = helpers.fake_fs 'empty_dir'
    em = traverse path
    em.on 'end', ->
      done()
  it 'should emit the `end` event after the `path` event', (done)->
    spy = sinon.spy()
    path = helpers.fake_fs 'empty_dir'
    em = traverse path
    em.on 'path', spy
    em.on 'end', ->
      spy.should.have.been.called
      done()
