mkdirp = require 'mkdirp'
_fs = require 'fs'
_path = require 'path'
fixtures = require '../fixtures/fs.json'

isDir = (d)->
  _fs.lstatSync(d).isDirectory()

root = 'tmp'
fixtureRoot = [process.cwd(), root].join '/'

_id = 0

module.exports =
  fake_fs: (fixtureName)->
    ++_id
    fixture = fixtures[fixtureName]
    for path, type of fixture
      _fullPath = [fixtureRoot, _id, path].join '/'
      if type
        mkdirp.sync _fullPath
      else
        mkdirp.sync(_path.dirname _fullPath)
        _fs.writeFileSync _fullPath, ''
    [root, _id, path].join '/'

module.exports.fake_fs.clean = ->
  (require 'rimraf').sync fixtureRoot
