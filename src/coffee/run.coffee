path = require('path')
_ = require('underscore')._
_s = require 'underscore.string'
Client = require '../lib/client'
Config = require('../config').config
Promise = require 'bluebird'
ProgressBar = require 'progress'

fs = Promise.promisifyAll require('fs')

processImages = (files) ->

  console.log()
  bar = new ProgressBar '  progress [:bar] :percent, :current of :total images done (time: elapsed :elapseds, estimated :etas)', {
    complete: '=',
    incomplete: ' ',
    width: 20,
    total: files.length
  }
  
  Promise.map files, (file) ->
    client.getFile(file.Key)
    .then (response) ->
      name = path.basename(file.Key)
      stream = fs.createWriteStream "/tmp/#{name}"
      new Promise (resolve, reject) ->
        response.pipe stream
        response.on 'end', resolve
        response.on 'error', reject
    .then ->
      name = path.basename(file.Key)
      client.resizeAndUpload file.Key, Config.descriptions[0].prefix, Config.descriptions[0].formats
    .then ->
      Promise.resolve bar.tick()
  , {concurrency: 10}

client = new Client Config.aws_key, Config.aws_secret, Config.aws_bucket


client.list { prefix: 'products/'}
.then (data) ->
  
  suffixes = _.map Config.descriptions[0].formats, (format) ->
    format.suffix
  
  # reject content representing a folder
  files = _.reject data.Contents, (content) ->
    content.Size == 0 || _.find suffixes, (suffix) ->
      content.Key.indexOf(suffix) > 0
    
  # process files
  processImages files
.catch (error) ->
  console.log error
