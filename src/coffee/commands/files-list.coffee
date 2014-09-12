debug = require('debug')('s3utils-files-list')
program = require 'commander'
Helpers = require '../helpers'
S3Client = require '../services/s3client'
{CustomError} = require '../errors'

program
.option '-c, --credentials <path>', 'set s3 credentials file path'
.option '-p, --prefix <name>', 'all files matching the prefix will be loaded'
.option '-r, --regex [name]', 'an optional RegExp used for filtering listed files (e.g.: /(.*)\.jpg/)', ''
.option '-l, --logFile <path>', 'optionally log to a file instead of printing to console (errors will still be printed to stderr)'
.parse process.argv

debug 'parsing args: %s', process.argv
Logger = require('../logger')(program.logFile)

try
  loadedCredentials = Helpers.loadCredentials(program.credentials)
  debug 'loaded credentials: %j', loadedCredentials

  if loadedCredentials and program.prefix

    s3client = new S3Client loadedCredentials

    Logger.info 'Fetching files...'
    s3client.filteredList {prefix: program.prefix}, program.regex
    .then (files) -> Logger.data 'Matched files', files: files
  else
    Logger.error 'Missing required arguments'
    program.help()
catch e
  if e instanceof CustomError
    Logger.error e.message
    process.exit 1
  else
    throw e
