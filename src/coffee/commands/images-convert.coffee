debug = require('debug')('s3utils-images-convert')
_ = require 'underscore'
program = require 'commander'
Promise = require 'bluebird'
Helpers = require '../helpers'
S3Client = require '../services/s3client'
{CustomError} = require '../errors'
tmp = Promise.promisifyAll require('tmp')

program
.option '-c, --credentials <path>', 'set s3 credentials file path'
.option '-d, --descriptions <path>', 'set image descriptions file path'
.option '-r, --regex [name]', 'an optional RegExp used for filtering listed files (e.g.: /(.*)\.jpg/)', ''
.option '-l, --logFile <path>', 'optionally log to a file instead of printing to console (errors will still be printed to stderr)'
.parse process.argv

debug 'parsing args: %s', process.argv
Logger = require('../logger')(program.logFile)

try
  loadedCredentials = Helpers.loadCredentials(program.credentials)
  debug 'loaded credentials: %j', loadedCredentials

  if loadedCredentials and program.descriptions
    # cleanup the temporary files even when an uncaught exception occurs
    tmp.setGracefulCleanup()

    s3client = new S3Client loadedCredentials, Logger
    descriptions = Helpers.parseJsonFromFile program.descriptions

    # unsafeCleanup: recursively removes the created temporary directory, even when it's not empty
    tmp.dirAsync {unsafeCleanup: true}
    .then (tmpDir) ->
      debug 'tmp folder created at %s', tmpDir
      Promise.map descriptions, (description) ->
        totFiles = 0
        headers = description.headers
        headers.prefix = description.prefix_unprocessed

        Logger.info 'Fetching images for prefix %s (with regex \'%s\')...', headers.prefix, program.regex
        s3client.filteredList headers, program.regex
        .then (files) ->
          totFiles = _.size(files)
          if totFiles > 0
            Logger.info 'Processing %s images with prefix %s', totFiles, headers.prefix
            bar = Logger.progress "Processing prefix '#{headers.prefix}':\t[:bar] :percent, :current of :total images done (time: elapsed :elapseds, eta :etas)", totFiles
            bar.update(0)
            s3client.on 'progress', -> bar.tick()

            # process files
            s3client.resizeAndUploadImages files, description, tmpDir
            .then ->
              Logger.info 'Finished processing / converting %s images for prefix %s', totFiles, headers.prefix
              Promise.resolve()
          else
            Logger.info 'No images to process for prefix', headers.prefix
            Promise.resolve()
      , {concurrency: 1}
      .then ->
        Logger.info 'Finished processing all given descriptions'
        process.exit 0
    .catch (error) ->
      debug 'caught error %s', error.stack
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
