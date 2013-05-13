var _ = require('underscore');

function noop () {  }

function _ErrorOrCallback (msg, cb) {
  if (cb && cb !== noop) {
    cb(msg);
  } else {
    throw new Error(msg);
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
      _ErrorOrCallback('path must be a String', cb);
    }

    cb();
    return {};
  }

  return obj;
};
