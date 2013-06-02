var _fs = require('fs'),
    _path = require('path'),
    EventEmitter = require('events').EventEmitter,
    q = require('q');

function _buildPath (c) {
  return traverse([this.path, c].join('/'), this.em);
}

function _read(err, children) {
  if (err) {
    return this.em.emit('error', err);
  }
  var path = this.path;
  var promises = children.map(_buildPath.bind(this));
  q.when(promises).then(
    this.dfd.resolve.bind(this.dfd, undefined),
    this.dfd.resolve.bind(this.dfd, undefined)
  );
}

function _stat (err, stat) {
  if (err) {
    return this.dfd.reject(err);
  }
  this.em.emit('path', this.path, stat);
  if (stat.isFile()) {
    this.dfd.resolve();
  } else if (stat.isDirectory()) {
    _fs.readdir(this.path, _read.bind(this));
  }
}

function traverse (rootPath, em) {
  var dfd = q.defer();
  _fs.lstat(rootPath, _stat.bind({em: em, path: rootPath, dfd: dfd}));
  return dfd.promise;
};

module.exports = function (rootPath) {
  var em = new EventEmitter();
  traverse(rootPath, em).then(
    em.emit.bind(em, 'end'),
    em.emit.bind(em, 'error')
  );
  return em;
};
