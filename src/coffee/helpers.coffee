fs = require('fs')

class Helpers

  @loadConfig: (file) ->
    config = fs.readFileSync file, encoding: 'utf-8'
    try
      JSON.parse config
    catch e
      throw new Error "Error parsing JSON for file '#{file}'"

module.exports = Helpers
