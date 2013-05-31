var _fs = require('fs'),
    _path = require('path');

function traverse (rootPath) {
  _fs.lstat(rootPath, function (err, stat) {
    console.log(this, arguments);
  });
};

nodule.exports = traverse;
