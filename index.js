var _ = require('underscore'),
    findit = require('findit');

function noop () {  }

function _ThrowOrCallback (err, cb) {
  if (cb && cb !== noop) {
    cb(err);
  } else {
    throw err;
  }
}

module.exports = function () {
  "use strict";

  var _entryProps = ['name', 'relativePath', 'fullPath', 'size', 'type'];

  var obj = {
    include: _include,
    describe: _describe,
    traverse: _traverse
  };

  function _include () {
    return obj;
  }

  function _describe () {
    return obj;
  }

  function _traverse (rootPath, cb) {
    if (!cb) {
      cb = noop;
    }
    if (cb && !_.isFunction(cb)) {
      throw new TypeError('The callback must be a function.');
    }
    if (!_.isString(rootPath)) {
      return _ThrowOrCallback(new Error('path must be a String'), cb);
    }

    var finder = findit.find(rootPath);
    var _hasErrors = false;
    var data = {};
    finder.on('path', function (file, stat) {
      var type;
      if (stat.isDirectory())     type = 'directory';
      if (stat.isFile())          type = 'file';
      if (stat.isSymbolicLink())  type = 'symlink';
      var splitPath = file.split('/').filter(function (e) {
        return e.length;
      });
      var name = file.split('/').filter(function (e) {
        return e.length;
      }).pop();
      var size = stat.size;
      var fullPath = (require('path')).resolve(file);
      var relativePathToSearchRoot = file.replace(rootPath, '').replace('/', ''); //a '/' could confuse with the FS root

      var _data = data;
      for (var i = 0; i < relativePathToSearchRoot.length; i++) {
        if (!_data.hasOwnProperty(relativePathToSearchRoot[i])) {
          // @TODO The following sucks monkey nalls
          _data[relativePathToSearchRoot[i]] = {};
        }
        _data = _data[relativePathToSearchRoot[i]];
      }
      _data.name = name;
      _data.relativePath = file;
      _data.fullPath = fullPath;
      _data.size = size;
      _data.type = type;
    });
    finder.on('end', function () {
      if (_hasErrors) {
        return _ThrowOrCallback(_hasErrors, cb);
      } else {
        console.warn(data);
        cb && cb(null, data);
      }
    });
    finder.on('error', function (err) {
      _hasErrors = err;
    });
  }

  return obj;
};
