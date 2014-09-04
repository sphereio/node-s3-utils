debug = require('debug')('s3utils-files-delete')
colors = require 'colors'
program = require 'commander'
Promise = require 'bluebird'
Helpers = require '../helpers'
Progress = require '../progress'
S3Client = require '../services/s3client'
{CustomError} = require '../errors'

try
  program
  .option '-c, --credentials <path>', 'set s3 credentials file path', Helpers.loadCredentials, Helpers.loadCredentials()
  .option '-s, --source <path>', 'local file path'
  .option '-t, --target <path>', 'target file path (in bucket)'
  .parse process.argv

  debug 'parsing args: %s', process.argv

  if program.credentials and program.source and program.target

    s3client = new S3Client program.credentials

    bar = Progress.init "Uploading file:\t[:bar] :percent, :current of :total files done (time: elapsed :elapseds, eta :etas)", 1
    # TODO: allow to pass headers
    debug 'about to upload file %s to %s', program.source, program.target
    s3client.putFileWithProgress program.source, program.target, {}, bar
    .then (resp) ->
      if resp.statusCode is 200
        console.log 'File successfully uploaded'.green
        process.exit 0
      else
        console.error "Response with code: #{resp.statusCode}".red
        process.exit 1
    .catch (error) ->
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
