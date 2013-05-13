# FS -> JSON

Translates a directory structure into a nice-formatted JSON object.

# How to use it ?

    var fs2json = require('fs2json'),
        rootDir = '~/example';

    fs2json()
      .describe(['name', 'relativePath', 'type', 'fullPath', 'size']) # Can be any combination of these values. Defaults to all.
      .include(['files', 'emptyDirs', 'links']) # Dirs with children can not be excluded. The value can be any combination of the values in the example. Defaults to all.
      .traverse(rootDir);

# Specs

The `rootDir` is always inclued in the result set, even if it is empty and emptyDir are explicitely not included.

_Links_ never show the full path to the source file.

## describe(opts)

## include(opts)

## traverse(dir, cb, errb)

# Licence

MIT


