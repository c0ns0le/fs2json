/*
 * @TODO Makes the callback mandatory or automatically turns synchronous if not present
 *
 */


var _ = require('underscore'),
    treeverse = require('./lib/traverse').Treeverse;

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
    path: rotPath,
    opts: opts,
    cb: cb
  };
}

/*
 * Adds properties to `this`, where `this` is an object literal
 * representing an entry in the filesystem
 *
 */
function _addProperties(file, relativePath, stat) {

  var type;
  if (stat.isFile())          type = 'file';
  if (stat.isSymbolicLink())  type = 'symlink';
  if (stat.isDirectory()) {
    type = 'directory';
    this.children = [];
  }

  var name = (require('path')).basename(file);

  var size = stat.size;

  var fullPath = (require('path')).resolve(file);

  this.name = name;
  this.relativePath = relativePath;
  this.fullPath = fullPath;
  this.size = size;
  this.type = type;
}

function _findChild (data, name) {
  if (!data.children) {
    return null;
  }
  var filtered = data.children.filter(function (elt) {
    return elt.name === name;
  });
  if (filtered.length) {
    return filtered[0];
  }
  return null;
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

  function _traverse (rootPath, opts, cb) {
    var args = _handleArgs.apply(undefined, arguments);

    var finder = new treeverse();
    var depthFilter = require('./lib/filters/depth')({
      depth: args.opts.depth,
      minDepth: args.opts.minDepth,
      maxDepth: args.opts.maxDepth,
      baseDir: args.path
    });
    finder
      .filter(depthFilter)
      .run(args.path, args.opts);
    var data = {};

    finder.on('path', function (file, stat) {
      var splitPath = file.replace(args.path, '').split('/').filter(function (e) {
        return e.length;
      });
      var relativePathToSearchRoot = file.replace(args.rootPath, '').replace('/', '');
      if (relativePathToSearchRoot.length) {
        relativePathToSearchRoot = relativePathToSearchRoot.split('/'); //a '/' could confuse with the FS root
      } else {
        relativePathToSearchRoot = [];
      }

      var _data = data;
      for (var i = 0; i < relativePathToSearchRoot.length; i++) {
        var _child = _findChild(_data, relativePathToSearchRoot[i]);
        if (!_child) {
          _child = {};
          // @TODO The following sucks monkey balls
          _data.children = _data.children || [];
          _data.children.push(_child);
        }
        _data = _child;
      }
      _addProperties.call(_data, file, relativePathToSearchRoot.join('/'), stat);
    });

    finder.on('end', function () {
      args.cb && args.cb(null, data);
    });

    finder.on('error', function (err) {
      return _ThrowOrCallback(err, args.cb);
    });
  }

  return obj;
};
