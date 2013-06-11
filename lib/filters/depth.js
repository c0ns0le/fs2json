"use strict";
var resolve = require('path').resolve;

module.exports = function (options) {
  options = options || {};
  var baseDir = options.baseDir || '';
  var baseDirDepth = (resolve(baseDir)).split('/').length;
  var max = !options.hasOwnProperty('maxDepth') ? Infinity : (isNaN(+options.maxDepth) ? Infinity : options.maxDepth),
      min = !options.hasOwnProperty('minDepth') ? 0 : (isNaN(+options.minDepth) ? 0 : options.minDepth),
      _depth;
  if (options.hasOwnProperty('depth')) {
    _depth = options.depth;
    if (!isNaN(+_depth)) {
      _depth = +_depth;
      max = _depth;
      min = _depth;
    }
  }
  var api = {
    quit: function (d) {
      return (d - baseDirDepth) > max;
    },
    valid: function (d) {
      d -= baseDirDepth;
      return d >= min && d <= max;
    }
  };

  return function (path/*, stat*/) {
    var depth = resolve(options.baseDir, path).split('/').length;
    if (api.quit(depth)) {
      this.break();
    }
    if (!api.valid(depth)) {
      this.drop();
    }
  };
};
