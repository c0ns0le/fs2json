filterStatus = require '../../lib/filterStatus'
sinon = require 'sinon'
chai = require 'chai'

chai.use require('sinon-chai')
expect = chai.expect

describe 'filterStatus', ->
  
  describe 'public API', ->
    it 'should be a function', ->
      filterStatus.should.be.a 'function'
    it 'should expose a facade for the filters', ->
      filterStatus().should.contain.keys ['facade']
      filterStatus().facade.should.have.keys ['break', 'continue', 'drop', 'keep']
      filterStatus().facade.break.should.be.a 'function'
      filterStatus().facade.continue.should.be.a 'function'
      filterStatus().facade.drop.should.be.a 'function'
      filterStatus().facade.keep.should.be.a 'function'
    it 'should give access to the status through functions', ->
      filterStatus().should.contain.keys ['brokenNode', 'droppedNode']
      filterStatus().brokenNode.should.be.a 'function'
      filterStatus().droppedNode.should.be.a 'function'
  
  describe 'defaults', ->
    it 'should state to not break after the node', ->
      expect(filterStatus().brokenNode()).to.be.false
    it 'should state to not drop the node', ->
      expect(filterStatus().droppedNode()).to.be.false
  

  describe 'behaviour', ->

    describe 'of `broken / not broken` state',->
      it 'should be able to switch from `no break` to `break` with `break` method', ->
        status = filterStatus()
        status.facade.break()
        expect(status.brokenNode()).to.be.true
      it 'should keep the default behaviour with `continue` method', ->
        status = filterStatus()
        status.facade.continue()
        expect(status.brokenNode()).to.be.false
      it 'should not be able to switch back from `break` to `no break` with `continue` method', ->
        status = filterStatus()
        status.facade.break()
        status.facade.continue()
        expect(status.brokenNode()).to.be.true

    describe 'of `dropped / not dropped` state',->
      it 'should be able to switch from `no drop` to `drop` with `drop` method', ->
        status = filterStatus()
        status.facade.drop()
        expect(status.droppedNode()).to.be.true
      it 'should keep the default behaviour with `keep` method', ->
        status = filterStatus()
        status.facade.keep()
        expect(status.droppedNode()).to.be.false
      it 'should not be able to switch back from `drop` to `no drop` with `keep`', ->
        status = filterStatus()
        status.facade.drop()
        status.facade.keep()
        expect(status.droppedNode()).to.be.true
