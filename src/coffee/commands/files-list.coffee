debug = require('debug')('s3utils-files-list')
_ = require 'underscore'
colors = require 'colors'
program = require 'commander'
Helpers = require '../helpers'
S3Client = require '../services/s3client'
{CustomError} = require '../errors'

try
  program
  .option '-c, --credentials <path>', 'set s3 credentials file path', Helpers.loadCredentials, Helpers.loadCredentials()
  .option '-p, --prefix <name>', 'all files matching the prefix will be loaded'
  .option '-r, --regex [name]', 'an optional RegExp used for filtering listed files (e.g.: /(.*)\.jpg/)', ''
  .parse process.argv

  debug 'parsing args: %s', process.argv

  if program.credentials and program.prefix

    s3client = new S3Client program.credentials

    console.log 'Fetching files...'
    s3client.list prefix: program.prefix
    .then (data) ->
      debug 'listing %s files', data.Contents.length
      # filter files from given regex
      regex = new RegExp program.regex, 'gi'
      debug 'using RegExp %s', regex
      files = _.filter data.Contents, (content) -> content.Key.match(regex)
      debug 'filtered %s files', files.length
      console.log JSON.stringify files, null, 2
  else
    console.log 'Missing required arguments'.red
    program.help()
catch e
  if e instanceof CustomError
    console.log e.message.red
    process.exit 1
  else
    throw e
