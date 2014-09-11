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
  .option '-c, --credentials <path>', 'set s3 credentials file path'
  .option '-s, --source <path>', 'local file path (if it\'s a folder, it will try to upload every file in it - subfolders will be ignored)'
  .option '-t, --target <path>', 'target file path (in bucket)'
  .parse process.argv

  debug 'parsing args: %s', process.argv

  loadedCredentials = Helpers.loadCredentials(program.credentials)
  debug 'loaded credentials: %j', loadedCredentials

  if loadedCredentials and program.source and program.target

    s3client = new S3Client loadedCredentials

    bar = Progress.init "Uploading file:\t[:bar] :percent, :current of :total files done (time: elapsed :elapseds, eta :etas)", 1
    # TODO: allow to pass headers
    debug 'about to upload file %s to %s', program.source, program.target
    s3client.putDir program.source, program.target, {}, bar
    .then ->
      console.log 'Files successfully uploaded'.green
      process.exit 0
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
