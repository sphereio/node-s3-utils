_ = require 'underscore'
debug = require('debug')('s3utils-files-delete')
program = require 'commander'
Promise = require 'bluebird'
Helpers = require '../helpers'
S3Client = require '../services/s3client'

program
.option '-c, --credentials <path>', 'set aws credentials file path'
.option '-p, --prefix <name>', 'all files matching the prefix will be loaded'
.option '-r, --regex [name]', 'an optional RegExp used for filtering listed products (e.g.: /(.*)\.jpg/)', ''
.parse process.argv

debug 'parsing args: %s', process.argv

if program.credentials and program.prefix

  credentials = Helpers.loadConfig program.credentials
  # TODO: nicer error message when credentials are missing
  s3client = new S3Client
    key: credentials.aws_key
    secret: credentials.aws_secret
    bucket: credentials.aws_bucket

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
        console.log 'Files successfully deleted'
        process.exit 0
      .catch (error) ->
        console.log error
        process.exit 1
    else
      console.log 'No files to be deleted'
      process.exit 0
else
  console.log 'Missing required arguments'
  program.help()
