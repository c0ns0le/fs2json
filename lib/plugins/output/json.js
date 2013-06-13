"use strict";

var pathModule = require('path');

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

  var name = pathModule.basename(file);

  var size = stat.size;

  var fullPath = pathModule.resolve(file);

  this.name = name;
  this.relativePath = relativePath;
  this.fullPath = fullPath;
  this.size = size;
  this.type = type;
}

module.exports = function (config) {
  var data = {};

  var plugin = function (file, stat) {
    var relativePathToSearchRoot = pathModule.relative(config.baseDir, file);
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
  };

  plugin.result = function () {
    return data;
  };

  return plugin;
};
