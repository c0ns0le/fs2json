var _fs = require('fs'),
    _path = require('path'),
    EventEmitter = require('events').EventEmitter;

function traverse (rootPath, em) {
  _fs.lstat(rootPath, function (err, stat) {
    if (err) {
      return em.emit('error', err);
    }
    em.emit('path', stat);
    if (stat.isFile()) {
      em.emit('end', stat);
    }
  });
};

module.exports = function (rootPath) {
  var em = new EventEmitter();
  traverse(rootPath, em);
  return em;
};
