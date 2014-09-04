debug = require('debug')('s3utils-files-delete')
_ = require 'underscore'
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
  .option '-p, --prefix <name>', 'all files matching the prefix will be loaded'
  .option '-r, --regex [name]', 'an optional RegExp used for filtering listed files (e.g.: /(.*)\.jpg/)', ''
  .option '--dry-run', 'list all files that will be deleted, but don\'t delete them', false
  .parse process.argv

  debug 'parsing args: %s', process.argv

  if program.credentials and program.prefix

    s3client = new S3Client program.credentials

    console.log 'Fetching files...'
    s3client.filteredList {prefix: program.prefix}, program.regex
    .then (files) ->

      if program.dryRun
        debug 'running is dry-run mode, no files will be deleted'
        console.log 'Following files will be deleted (if run without dry mode)'.blue
        console.log JSON.stringify files, null, 2
      else
        if _.size(files) > 0
          bar = Progress.init "Deleting files:\t[:bar] :percent, :current of :total files done (time: elapsed :elapseds, eta :etas)", _.size(files)
          bar.update(0)
          s3client.on 'progress', -> bar.tick()

          Promise.map files, (file) ->
            debug 'about to delete file %s', file.Key
            s3client.deleteFile file.Key
            .then -> Promise.resolve s3client.emit 'progress'
          , {concurrency: 5}
          .then ->
            console.log 'Files successfully deleted'.green
            process.exit 0
          .catch (error) ->
            console.log error.message.red
            process.exit 1
        else
          console.log 'No files to be deleted'.green
          process.exit 0
  else
    console.log 'Missing required arguments'.red
    program.help()
catch e
  if e instanceof CustomError
    console.log e.message.red
    process.exit 1
  else
    throw e
