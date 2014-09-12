debug = require('debug')('s3utils-logger')
_ = require 'underscore'
winston = require 'winston'
ProgressBar = require 'progress'

###*
 * A custom wrapper of {ProgressBar}, allowing to log progress percentage (e.g. in a file)
###
class FileProgress

  ###*
   * @constructor
   * Initializes the class
   * @param  {Logger} log An instance of a {Logger}
   * @param  {Number} total The total amount to calculate the progress
  ###
  constructor: (@log, @total) ->
    @current = 0

  ###*
   * @private
   * Terminates the progress
  ###
  _terminate: -> @current = 0

  ###*
   * Increments the progress with an optional 'len'
   * @param  {Number} [len] Optional progress
  ###
  tick: (len) ->
    if len isnt 0
      len = len or 1

    @current += len
    ratio = @current / @total
    ratio = Math.min(Math.max(ratio, 0), 1)

    debug 'tick: current (%s), total (%s), ratio (%s)', @current, @total, ratio
    @log.info 'Progress: %s% (%s / %s)', (ratio * 100).toFixed(0), @current, @total
    # progress complete
    if @current >= @total
      @_terminate()

  ###*
   * Updates the progress to represent an exact percentage
   * @param  {Number} ratio The ratio (between 0 and 1, inclusive) to set the overall completion to
  ###
  update: (ratio) ->
    goal = Math.floor(ratio * @total)
    delta = goal - @current
    @tick(delta)


###*
 * A custom wrapper of a {winston} logger
###
class Logger

  ###*
   * @constructor
   * Initializes the logger, based on the given argument
   * - if logFile is present, the transport will be File (+ Console for stderr)
   * - if logFile is not present, uses Console transport
   * @param  {String} [logFile] An optional path to a log file
  ###
  constructor: (logFile) ->
    if logFile
      debug 'using logger with files + console transports (%s)', logFile
      @_logToFile = true
      @_logger = new winston.Logger
        transports: [
          # TODO: throw new CustomError if file doesn't exist
          new winston.transports.File
            timestamp: true
            filename: logFile
          new winston.transports.Console
            level: 'error'
        ]
    else
      debug 'using logger with console only transports'
      @_logToFile = false
      @_logger = new winston.Logger
        transports: [
          new winston.transports.Console
            colorize: true
            prettyPrint: true
        ]
        colors: _.extend winston.config.cli.colors,
          data: 'cyan'

    # Important: will enable special helpers for CLI usage
    # https://github.com/flatiron/winston#using-winston-in-a-cli-tool
    @_logger.cli()

  ###*
   * Wrappers / aliases for {winston} log levels
  ###
  silly: -> @_logger.silly.apply(@, arguments)
  input: -> @_logger.input.apply(@, arguments)
  verbose: -> @_logger.verbose.apply(@, arguments)
  prompt: -> @_logger.prompt.apply(@, arguments)
  debug: -> @_logger.debug.apply(@, arguments)
  info: -> @_logger.info.apply(@, arguments)
  data: -> @_logger.data.apply(@, arguments)
  help: -> @_logger.help.apply(@, arguments)
  warn: -> @_logger.warn.apply(@, arguments)
  error: -> @_logger.error.apply(@, arguments)
  log: -> @_logger.log.apply(@, arguments)

  ###*
   * Will automatically detect how to show progress
   * - if File transport is enabled uses {FileProgress}
   * - if only Console transport is enabled uses {ProgressBar}
   * @param  {String} message The tokenized message to print progress (used by {ProgressBar} only)
   * @param  {Number} total The total amount to calculate the progress
   * @return {Object} Either an instance of {FileProgress} or {ProgressBar}
  ###
  progress: (message, total) ->
    if @_logToFile
      new FileProgress @_logger, total
    else
      new ProgressBar message,
        complete: '='
        incomplete: ' '
        width: 20
        total: total

module.exports = (logFile) -> new Logger logFile
