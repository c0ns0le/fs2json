"use strict";

module.exports = function (options) {
  options = options || {};
  var baseDirDepth = (options.baseDir || '').split('/').length;
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
      return d > max;
    },
    valid: function (d) {
      return d >= min && d <= max;
    }
  };

  return function (path, stat) {
    var depth = path.replace(/\/*$/g, '').split('/').length;
    if (api.quit(depth - baseDirDepth)) {
      this.break();
    }
    if (!api.valid(depth - baseDirDepth)) {
      this.drop();
    }
  };
};
