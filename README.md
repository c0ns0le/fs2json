# FS2JSON

> This is an early version, currently in development, therefore not featureful yet, you'd better not use it right now
> Unless you want to participate or make comments :wink:

Translates a directory structure into a nice-formatted JSON object.

# How to use it ?

    var fs2json = require('fs2json'),
        rootDir = '~/example';

    function _cb = function (err, data) {
      //Whatever you need to do with the data...
    }

    fs2json()
      .describe(['name', 'relativePath', 'type', 'fullPath', 'size']) # Can be any combination of these values. Defaults to all.
      .include(['files', 'emptyDirs', 'links']) # Dirs with children can not be excluded. The value can be any combination of the values in the example. Defaults to all.
      .traverse(rootDir, _cb);

# Specs

The `rootDir` is always included in the result set, even if it is empty and emptyDir are explicitely not included.

_Links_ never show the full path to the source file.

## describe(opts)

__WIP__

## include(opts)

__WIP__

## traverse(dir, cb)

Takes a `String` as the first parameter, the path will be calculated relatively to the __project root__.

The `cb` is a `(err, data)`-style function.

# Licence

MIT


