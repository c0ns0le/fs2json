var _fs = require('fs'),
    _path = require('path'),
    EventEmitter = require('events').EventEmitter,
    q = require('q');

function traverse (rootPath, em) {
  var dfd = q.defer();
  _fs.lstat(rootPath, function (err, stat) {
    if (err) {
      return dfd.reject(err);
    }
    em.emit('path', rootPath, stat);
    if (stat.isFile()) {
      dfd.resolve();
    } else if (stat.isDirectory()) {
      _fs.readdir(rootPath, function (err, children) {
        if (err) {
          return em.emit('error', err);
        }
        var promises = children.map(function (c) {
          traverse([rootPath, c].join('/'), em);
        });
        q.when(promises).then(
          dfd.resolve.bind(dfd, undefined),
          dfd.resolve.bind(dfd, undefined)
        );
      });
    }
  });
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
