traverse = require '../lib/travserse'
sinon = require 'sinon'

describe 'Traversing a file', ->
  it 'should emit a `path` event', (done)->
    em = traverse './fixtures/file'
    em.on 'path', ->
      done()
  it 'should emit a `end` event', (done)->
    em = traverse './fixtures/file'
    em.on 'end', ->
      done()
  it 'should emit the `end` event after the `path` event', (done)->
    em = traverse './fixtures/file'
    spy = sinon.spy()
    em.on 'path', spy
    em.on 'end', ->
      spy.should.eve.been.called
      done()

