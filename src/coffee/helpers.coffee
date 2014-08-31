fs = require 'fs'

class Helpers
  
  @loadConfig: (file) ->
    try
      config = JSON.parse fs.readFileSync(file).toString()

      config || {}
    catch ex
      console.log "Error parsing #{config}"
      ex.stack.split('\n').forEach (line) ->
        console.log line
      process.exit 1

module.exports = Helpers
