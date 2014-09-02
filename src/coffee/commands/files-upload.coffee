debug = require('debug')('s3utils-files-delete')
program = require 'commander'
Promise = require 'bluebird'
Helpers = require '../helpers'
S3Client = require '../services/s3client'

program
.option '-c, --credentials <path>', 'set aws credentials file path'
.option '-s, --source <path>', 'local file path'
.option '-t, --target <path>', 'target file path (in bucket)'
.parse process.argv

debug 'parsing args: %s', process.argv

if program.credentials and program.source and program.target
  credentials = Helpers.loadConfig program.credentials
  # TODO: nicer error message when credentials are missing
  s3client = new S3Client
    key: credentials.aws_key
    secret: credentials.aws_secret
    bucket: credentials.aws_bucket

  debug 'about to upload file %s to %s', program.source, program.target
  # TODO: allow to pass headers
  s3client.putFile program.source, program.target, {}
  .then (resp) ->
    if resp.statusCode is 200
      console.log 'File successfully uploaded'
      process.exit 0
    else
      process.exit 1
  .catch (error) ->
    console.log error
    process.exit 1
else
  console.log 'Missing required arguments'
  program.help()
