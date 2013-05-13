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

  function _traverse (path, cb) {
    if (!cb) {
      cb = noop;
    }
    if (cb && !_.isFunction(cb)) {
      throw new TypeError('The callback must be a function.');
    }
    if (!_.isString(path)) {
      return _ThrowOrCallback(new Error('path must be a String'), cb);
    }

    var finder = findit.find(path);
    var _hasErrors = false;
    finder.on('path', function (file, stat) {
      if (file instanceof Error) {
        _hasErrors = file;
      }
    });
    finder.on('end', function () {
      if (_hasErrors) {
        return _ThrowOrCallback(_hasErrors, cb);
      } else {
        cb && cb(null, {});
      }
    });
    finder.on('error', function (err) {
      _hasErrors = err;
    });
  }

  return obj;
};
