ProgressBar = require 'progress'

module.exports = class
  @init: (message, total) ->
    new ProgressBar message,
      complete: '='
      incomplete: ' '
      width: 20
      total: total