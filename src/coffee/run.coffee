path = require('path')
_ = require('underscore')._
_s = require 'underscore.string'
Client = require '../lib/client'
Config = require('../config').config
Promise = require 'bluebird'
ProgressBar = require 'progress'

client = new Client Config.aws_key, Config.aws_secret, Config.aws_bucket

Promise.map Config.descriptions, (description) ->
  client.list description.headers
  .then (data) ->
    suffixes = _.map description.formats, (format) ->
      format.suffix
  
    # reject content representing a folder
    files = _.reject data.Contents, (content) ->
      content.Size == 0 || _.find suffixes, (suffix) ->
        content.Key.indexOf(suffix) > 0
    
    # process files
    client.resizeAndUploadImages files, description
, {concurrency: 1}
.catch (error) ->
  console.log error
