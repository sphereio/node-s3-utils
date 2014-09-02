_ = require 'underscore'
program = require 'commander'
Promise = require 'bluebird'
Helpers = require '../helpers'
S3Client = require '../services/s3client'
tmp = Promise.promisifyAll require('tmp')

program
.option '-c, --credentials <path>', 'set aws credentials file path'
.option '-d, --descriptions <path>', 'set image descriptions file path'
.parse process.argv

if program.credentials and program.descriptions
  # cleanup the temporary files even when an uncaught exception occurs
  tmp.setGracefulCleanup()

  credentials = Helpers.loadConfig program.credentials
  descriptions = Helpers.loadConfig program.descriptions
  # TODO: nicer error message when credentials are missing
  s3client = new S3Client
    key: credentials.aws_key
    secret: credentials.aws_secret
    bucket: credentials.aws_bucket

  # unsafeCleanup: recursively removes the created temporary directory, even when it's not empty
  tmp.dirAsync {unsafeCleanup: true}
  .then (tmpDir) ->
    Promise.map descriptions, (description) ->

      headers = description.headers
      headers.prefix = description.prefix_unprocessed

      s3client.list headers
      .then (data) ->
        # reject content representing a folder
        files = _.reject data.Contents, (content) -> content.Size is 0
        # process files
        s3client.resizeAndUploadImages files, description, tmpDir
    , {concurrency: 1}
  .catch (error) ->
    console.log error
    process.exit 1
else
  console.log 'Missing required arguments'
  program.help()
