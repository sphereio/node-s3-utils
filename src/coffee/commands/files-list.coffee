debug = require('debug')('s3utils-files-list')
_ = require 'underscore'
colors = require 'colors'
program = require 'commander'
Helpers = require '../helpers'
S3Client = require '../services/s3client'
{CustomError} = require '../errors'

try
  program
  .option '-c, --credentials <path>', 'set s3 credentials file path'
  .option '-p, --prefix <name>', 'all files matching the prefix will be loaded'
  .option '-r, --regex [name]', 'an optional RegExp used for filtering listed files (e.g.: /(.*)\.jpg/)', ''
  .parse process.argv

  debug 'parsing args: %s', process.argv

  loadedCredentials = Helpers.loadCredentials(program.credentials)
  debug 'loaded credentials: %j', loadedCredentials

  if loadedCredentials and program.prefix

    s3client = new S3Client loadedCredentials

    console.log 'Fetching files...'
    s3client.filteredList {prefix: program.prefix}, program.regex
    .then (files) -> console.log JSON.stringify files, null, 2
  else
    console.log 'Missing required arguments'.red
    program.help()
catch e
  if e instanceof CustomError
    console.log e.message.red
    process.exit 1
  else
    throw e
