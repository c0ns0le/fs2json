var _fs = require('fs'),
    _path = require('path'),
    EventEmitter = require('events').EventEmitter,
    async = require('async');

function _nodeStat (path, stat) {
  this.emit('path', path, stat);
  if (stat.isFile()) {
    this.emit('end');
  } else if (stat.isDirectory()) {
    _fs.readdir(path, function (err, children) {
      if (err) {
        return this.emit('error', err);
      }
      _readNode.call(this, path, children);
    }.bind(this));
  }
}

function _readNode(path, children) {
  var children = children.map(function (c) {
    var treeverse = new Treeverse();
    treeverse.on('path', this.emit.bind(this, 'path'));
    return function (cb) {
      treeverse.on('error', cb.bind(this));
      treeverse.on('end', cb.bind(this, undefined));
      treeverse.run([path, c].join('/'));
    }
  }.bind(this));

  async.parallel(children, function (err, children) {
    this.emit.apply(this, err ? ['error', err] : ['end']);
  }.bind(this));
}

function Treeverse() {
  EventEmitter.call(this);
}

require('util').inherits(Treeverse, EventEmitter);

Treeverse.prototype.run = function (rootPath) {
  _fs.lstat(rootPath, function (err, stat) {
    if (err) {
      return this.emit('error', err);
    }
    _nodeStat.call(this, rootPath, stat);
  }.bind(this));
}

module.exports = function (rootPath) {
  var treeverse = new Treeverse();
  treeverse.run(rootPath);
  return treeverse;
};
