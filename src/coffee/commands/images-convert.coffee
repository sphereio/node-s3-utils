_ = require 'underscore'
program = require 'commander'
Promise = require 'bluebird'
Client = require '../client'
Helpers = require '../helpers'

program
.option '-c, --credentials <path>', 'set aws credentials file path'
.option '-d, --descriptions <path>', 'set image descriptions file path'
.parse process.argv

program.help() unless program.args.length

if program.credentials and program.descriptions

  credentials = Helpers.loadConfig program.credentials
  descriptions = Helpers.loadConfig program.descriptions
  client = new Client
    key: credentials.aws_key
    secret: credentials.aws_secret
    bucket: credentials.aws_bucket

  Promise.map descriptions, (description) ->

    headers = description.headers
    headers.prefix = description.prefix_unprocessed

    client.list headers
    .then (data) ->
      # reject content representing a folder
      files = _.reject data.Contents, (content) ->
        content.Size is 0
      # process files
      client.resizeAndUploadImages files, description
  , {concurrency: 1}
  .catch (error) ->
    console.log error
    process.exit 1
else
  program.help()
