"use strict";

/*
 * @TODO Makes the callback mandatory or automatically turns synchronous if not present
 *
 */


var _ = require('underscore'),
    treeverse = require('./lib/traverse').Treeverse,
    pathModule = require('path');

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

function _handleArgs(rootPath, opts, cb) {
  if (_.isFunction(opts)) {
    cb = opts;
    opts = {};
  }
  if (cb && !_.isFunction(cb)) {
    return _ThrowOrCallback(new TypeError('The callback must be a function.'));
  }
  if (_.isObject(rootPath)) {
    opts = rootPath;
    rootPath = opts.path;
  }

  if (!_.isString(rootPath)) {
    return _ThrowOrCallback(new Error('no path given'), cb);
  }

  if (!opts) {
    opts = {};
  }

  return {
    path: rootPath,
    opts: opts,
    cb: cb
  };
}

function _traverse (/* rootPath, opts, cb */) {
  var args = _handleArgs.apply(undefined, arguments);
  args.path = pathModule.resolve(args.path);

  var finder = new treeverse();
  var depthFilter = require('./lib/filters/depth')({
    depth: args.opts.depth,
      minDepth: args.opts.minDepth,
      maxDepth: args.opts.maxDepth,
      baseDir: args.path
  });
  var jsonBuilder = require('./lib/plugins/output/json')({
    baseDir: args.path
  });
  finder
    .filter(depthFilter)
    .run(args.path, args.opts);

  finder.on('path', jsonBuilder);
  finder.on('end', function () {
    args.cb && args.cb(null, jsonBuilder.result());
  });

  finder.on('error', function (err) {
    return _ThrowOrCallback(err, args.cb);
  });
};

module.exports = function () {
  return {
    traverse: _traverse
  };
};
