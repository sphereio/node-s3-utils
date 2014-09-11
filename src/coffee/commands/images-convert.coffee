debug = require('debug')('s3utils-images-convert')
_ = require 'underscore'
colors = require 'colors'
program = require 'commander'
Promise = require 'bluebird'
Helpers = require '../helpers'
Progress = require '../progress'
S3Client = require '../services/s3client'
{CustomError} = require '../errors'
tmp = Promise.promisifyAll require('tmp')

try
  program
  .option '-c, --credentials <path>', 'set s3 credentials file path'
  .option '-d, --descriptions <path>', 'set image descriptions file path'
  .option '-r, --regex [name]', 'an optional RegExp used for filtering listed files (e.g.: /(.*)\.jpg/)', ''
  .parse process.argv

  debug 'parsing args: %s', process.argv

  loadedCredentials = Helpers.loadCredentials(program.credentials)
  debug 'loaded credentials: %j', loadedCredentials

  if loadedCredentials and program.descriptions
    # cleanup the temporary files even when an uncaught exception occurs
    tmp.setGracefulCleanup()

    s3client = new S3Client loadedCredentials
    descriptions = Helpers.parseJsonFromFile program.descriptions

    # unsafeCleanup: recursively removes the created temporary directory, even when it's not empty
    tmp.dirAsync {unsafeCleanup: true}
    .then (tmpDir) ->
      debug 'tmp folder created at %s', tmpDir
      Promise.map descriptions, (description) ->

        headers = description.headers
        headers.prefix = description.prefix_unprocessed

        s3client.filteredList headers, program.regex
        .then (files) ->

          if _.size(files) > 0
            bar = Progress.init "Processing prefix '#{headers.prefix}':\t[:bar] :percent, :current of :total images done (time: elapsed :elapseds, eta :etas)", _.size(files)
            bar.update(0)
            s3client.on 'progress', -> bar.tick()

            # process files
            s3client.resizeAndUploadImages files, description, tmpDir
          else
            console.log "No images to process for prefix #{headers.prefix}".blue
            Promise.resolve()
      , {concurrency: 1}
      .then ->
        console.log 'Images successfully converted'.green
        process.exit 0
    .catch (error) ->
      debug 'caught error %s', error.stack
      console.log error.message.red
      process.exit 1
  else
    console.log 'Missing required arguments'.red
    program.help()
catch e
  if e instanceof CustomError
    console.log e.message.red
    process.exit 1
  else
    throw e
