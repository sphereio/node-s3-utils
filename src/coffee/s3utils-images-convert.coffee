#!/usr/bin/env node
program = require 'commander'
path = require('path')
_ = require('underscore')._
_s = require 'underscore.string'
Client = require '../lib/client'
Helpers = require '../lib/helpers'
Promise = require 'bluebird'
ProgressBar = require 'progress'

program
.option '-c, --credentials <path>', 'set aws credentials file path'
.option '-d, --descriptions <path>', 'set image descriptions file path'
.parse process.argv

if !program.credentials || !program.descriptions
  program.outputHelp()
  process.exit 1

credentials = Helpers.loadConfig program.credentials
descriptions = Helpers.loadConfig program.descriptions

client = new Client credentials.aws_key, credentials.aws_secret, credentials.aws_bucket

Promise.map descriptions, (description) ->
  client.list description.headers
  .then (data) ->
    # reject content representing a folder
    files = _.reject data.Contents, (content) ->
      content.Size == 0
    # process files
    client.resizeAndUploadImages files, description
, {concurrency: 1}
.catch (error) ->
  console.log error
  process.exit 1
