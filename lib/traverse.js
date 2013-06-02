var _fs = require('fs'),
    _path = require('path'),
    EventEmitter = require('events').EventEmitter,
    async = require('async');

function Treeverse() {
  EventEmitter.call(this);
}
require('util').inherits(Treeverse, EventEmitter);

Treeverse.prototype.run = function (rootPath) {
  _fs.lstat(rootPath, function (err, stat) {
    if (err) {
      return this.emit('error', err);
    }
    this.nodeStat(rootPath, stat);
  }.bind(this));
}

Treeverse.prototype.nodeStat = function (path, stat) {
  this.emit('path', path, stat);
  if (stat.isFile()) {
    this.emit('end');
  } else if (stat.isDirectory()) {
    _fs.readdir(path, function (err, children) {
      if (err) {
        return this.emit('error', err);
      }
      this.readNode(path, children)
    }.bind(this));
  }
}

Treeverse.prototype.readNode = function (path, children) {
  var children = children.map(function (c) {
    var treeverse = new Treeverse();
    treeverse.on('path', this.emit.bind(this, 'path'));
    return function (cb) {
      treeverse.on('error', function (e) {
        cb(e);
      });
      treeverse.on('end', function () {
        cb();
      });
      treeverse.run([path, c].join('/'))
    }
  }.bind(this));

  async.parallel(children, function (err, children) {
    if (err) {
      this.emit('error', err)
    } else {
      this.emit('end');
    }
  }.bind(this));
}

module.exports = function (rootPath) {
  var treeverse = new Treeverse();
  treeverse.run(rootPath);
  return treeverse;
};
