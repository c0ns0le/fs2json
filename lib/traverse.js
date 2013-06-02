"use strict";

var _fs = require('fs'),
    EventEmitter = require('events').EventEmitter,
    createFilterStatus = require('./filterStatus'),
    async = require('async');

function _nodeStat (path, stat) {
  var filterStatus = createFilterStatus();
  this._filters.forEach(function(filter) {
    filter.call(filterStatus.facade, path, stat);
  });
  if (!filterStatus.droppedNode()) {
    this.emit('path', path, stat);
  }
  if (stat.isFile()) {
    this.emit('end');
  } else if (stat.isDirectory()) {
    if (filterStatus.brokenNode()) {
      this.emit('end');
    } else {
      _fs.readdir(path, function (err, children) {
        if (err) {
          return this.emit('error', err);
        }
        _readNode.call(this, path, children);
      }.bind(this));
    }
  }
}

function _readNode(path, children) {
  children = children.map(function (c) {
    var treeverse = new Treeverse();
    treeverse._filters = this._filters;
    treeverse.on('path', this.emit.bind(this, 'path'));
    return function (cb) {
      treeverse.on('error', cb.bind(this));
      treeverse.on('end', cb.bind(this, undefined));
      treeverse.run([path, c].join('/'));
    };
  }.bind(this));

  async.parallel(children, function (err, children) {
    this.emit.apply(this, err ? ['error', err] : ['end']);
  }.bind(this));
}

function Treeverse() {
  EventEmitter.call(this);
  this._filters = [];
}

require('util').inherits(Treeverse, EventEmitter);

Treeverse.prototype.run = function (rootPath) {
  _fs.lstat(rootPath, function (err, stat) {
    if (err) {
      return this.emit('error', err);
    }
    _nodeStat.call(this, rootPath, stat);
  }.bind(this));
};

Treeverse.prototype.filter = function (filter) {
  this._filters.push(filter);
  return this;
};

module.exports = function (rootPath) {
  var treeverse = new Treeverse();
  treeverse.run(rootPath);
  return treeverse;
};
module.exports.Treeverse = Treeverse;
