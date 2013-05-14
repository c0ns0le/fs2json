/*
 * @TODO Makes the callback mandatory or automatically turns synchronous if not present
 *
 */


var _ = require('underscore'),
    findit = require('findit');

/*
 * Default function in case no callback is provided
 *
 */
function noop () {  }

/*
 * Throws if no callback is available or cb is  noop
 *
 */
function _ThrowOrCallback (err, cb) {
  if (cb && cb !== noop) {
    cb(err);
  } else {
    throw err;
  }
}

/*
 * Adds properties to `this`, where `this` is an object literal
 * representing an entry in the filesystem
 *
 */
function _addProperties(file, stat) {

  var type;
  if (stat.isFile())          type = 'file';
  if (stat.isSymbolicLink())  type = 'symlink';
  if (stat.isDirectory()) {
    type = 'directory';
    this.children = [];
  }

  var name = file.split('/').filter(function (e) {
    return e.length;
  }).pop();

  var size = stat.size;

  var fullPath = (require('path')).resolve(file);

  this.name = name;
  this.relativePath = file;
  this.fullPath = fullPath;
  this.size = size;
  this.type = type;
}


module.exports = function () {
  "use strict";

  var _entryProps = ['name', 'relativePath', 'fullPath', 'size', 'type'];

  /*
   * The returned object
   */
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
      var splitPath = file.split('/').filter(function (e) {
        return e.length;
      });
      var relativePathToSearchRoot = file.replace(rootPath, '').replace('/', ''); //a '/' could confuse with the FS root

      var _data = data;
      for (var i = 0; i < relativePathToSearchRoot.length; i++) {
        if (!_data.hasOwnProperty(relativePathToSearchRoot[i])) {
          // @TODO The following sucks monkey nalls
          _data.children = _data.children || [];
          _data.children.push[relativePathToSearchRoot[i]] = {};
        }
        _data = _data[relativePathToSearchRoot[i]];
      }
      _addProperties.call(_data, file, stat);
    });

    finder.on('end', function () {
      if (_hasErrors) {
        return _ThrowOrCallback(_hasErrors, cb);
      } else {
        cb && cb(null, data);
      }
    });

    finder.on('error', function (err) {
      _hasErrors = err;
    });
  }

  return obj;
};
