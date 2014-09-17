debug = require('debug')('s3utils-files-delete')
program = require 'commander'
Promise = require 'bluebird'
Helpers = require '../helpers'
S3Client = require '../services/s3client'
{CustomError} = require '../errors'

program
.option '-c, --credentials <path>', 'set s3 credentials file path'
.option '-s, --source <path>', 'local file path (if it\'s a folder, it will try to upload every file in it - subfolders will be ignored)'
.option '-t, --target <path>', 'target file path (in bucket)'
.option '-l, --logFile <path>', 'optionally log to a file instead of printing to console (errors will still be printed to stderr)'
.option '--sendMetrics', 'optionally send statsd metrics', false
.option '--metricsPrefix <name>', 'optionally specify a prefix for the metrics'
.parse process.argv

debug 'parsing args: %s', process.argv
Logger = require('../logger')(program.logFile)

try
  loadedCredentials = Helpers.loadCredentials(program.credentials)
  debug 'loaded credentials: %j', loadedCredentials

  if loadedCredentials and program.source and program.target

    s3client = new S3Client _.extend loadedCredentials,
      logger: Logger
      metrics:
        active: program.sendMetrics
        prefix: program.metricsPrefix
    s3client.sendMetrics 'increment', 'commands.files.upload'

    Logger.info 'About to upload files to %s ...', program.target
    bar = Logger.progress "Uploading file:\t[:bar] :percent, :current of :total files done (time: elapsed :elapseds, eta :etas)", 1
    # TODO: allow to pass headers
    debug 'about to upload file %s to %s', program.source, program.target
    s3client.putDir program.source, program.target, {}, bar
    .then ->
      Logger.info 'Files successfully uploaded to %s'
      process.exit 0
    .catch (error) ->
      Logger.error error.message
      process.exit 1
  else
    Logger.error 'Missing required arguments'
    program.help()
catch e
  if e instanceof CustomError
    Logger.error e.message
    process.exit 1
  else
    throw e
