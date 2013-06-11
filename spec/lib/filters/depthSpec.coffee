depthFilter = require '../../../lib/filters/depth'
filterStatus = require '../../../lib/filterStatus'
sinon = require 'sinon'
chai = require 'chai'

chai.use require('sinon-chai')
expect = chai.expect

#@TODO Double check these specs, they're not trust-worthy
describe 'Filtering by depth', ->
  beforeEach ->
    @filterStatus = filterStatus()

  describe 'at depth 0', ->
    before ->
      @filter = depthFilter
        depth: 0,
        baseDir: '.'

    describe 'when the path starts with a "/"', ->
      it 'should be true with "/"', ->
        @filter.call @filterStatus.facade, '/'
        expect(@filterStatus.isDroppedNode()).to.be.true
      it 'should be false with any other value', ->
        @filter.call @filterStatus.facade, '/b'
        expect(@filterStatus.isDroppedNode()).to.be.true
    
    describe 'when the path starts with a "."', ->
      it 'should be true with "."', ->
        @filter.call @filterStatus.facade, '.'
        expect(@filterStatus.isDroppedNode()).to.be.false
      it 'should be true with "./"', ->
        @filter.call @filterStatus.facade, './'
        expect(@filterStatus.isDroppedNode()).to.be.false

    describe 'otherwise', ->
      it 'should be false', ->
        @filter.call @filterStatus.facade, 'a'
        expect(@filterStatus.isDroppedNode()).to.be.true
        @filter.call @filterStatus.facade, 'a/b'
        expect(@filterStatus.isDroppedNode()).to.be.true


