debug = require('debug')('s3utils-files-delete')
_ = require 'underscore'
colors = require 'colors'
program = require 'commander'
Promise = require 'bluebird'
Helpers = require '../helpers'
S3Client = require '../services/s3client'

program
.option '-c, --credentials <path>', 'set s3 credentials file path', Helpers.loadCredentials, Helpers.loadCredentials()
.option '-p, --prefix <name>', 'all files matching the prefix will be loaded'
.option '-r, --regex [name]', 'an optional RegExp used for filtering listed products (e.g.: /(.*)\.jpg/)', ''
.parse process.argv

debug 'parsing args: %s', process.argv

if program.credentials and program.prefix

  # TODO: nicer error message when credentials are missing
  s3client = new S3Client program.credentials

  debug 'using RegExp %s', program.regex
  s3client.list prefix: program.prefix
  .then (data) ->
    debug 'listing %s files', data.Contents.length
    # filter files from given regex
    regex = new RegExp program.regex, 'gi'
    files = _.filter data.Contents, (content) -> regex.test(content.Key)
    debug 'filtered %s files', files.length

    if _.size(files) > 0
      Promise.map files, (file) ->
        debug 'about to delete file %s', file.Key
        s3client.deleteFile file.Key
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
