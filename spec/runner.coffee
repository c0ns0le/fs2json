specFiles = [
  'index.coffee',
  'lib/traverse.coffee',
  'lib/filterStatus.coffee',
  'lib/filters/depthSpec.coffee'
]




cs = require 'coffee-script-redux'
cs.register()
mocha = new (require 'mocha')();
mocha.reporter 'spec'
mocha.files = specFiles.map (f)->
  return [__dirname, f].join '/'
mocha.run process.exit
