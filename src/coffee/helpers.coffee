class Helpers

  @loadConfig: (file) ->
    try
      require file
    catch e
      console.log "Error parsing config for file #{file}"
      # TODO: better logging
      e.stack.split('\n').forEach (line) -> console.log line
      process.exit 1

module.exports = Helpers
