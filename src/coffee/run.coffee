path = require('path')
_ = require('underscore')._
_s = require 'underscore.string'
Client = require '../lib/client'
Config = require('../config').config
Promise = require 'bluebird'

fs = Promise.promisifyAll require('fs')

descriptions =
  [
    {
      prefix: "products/"
      formats: [
        {
          suffix: "_thumbnail"
          width: 240
          height: 240
        },
        {
          suffix: "_small"
          width: 350
          height: 440
        },
        {
          suffix: "_medium"
          width: 540
          height: 740
        },
        {
          suffix: "_large"
          width: 1121
          height: 1500
        },
        {
          suffix: "_zoom"
          width: 1716
          height: 2288
        }
      ]
    }
  ]

processImages = (files) ->
  console.log "Resizing #{files.length} images..."
  counter = 0
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
      client.resizeAndUpload file.Key, "products/",
        [
          {
            suffix: "_thumbnail"
            width: 240
            height: 240
          },
          {
            suffix: "_small"
            width: 350
            height: 440
          },
          {
            suffix: "_medium"
            width: 540
            height: 740
          },
          {
            suffix: "_large"
            width: 1121
            height: 1500
          },
          {
            suffix: "_zoom"
            width: 1716
            height: 2288
          }
        ]
    .then ->
      counter++
      console.log "#{counter}/#{files.length}"
      Promise.resolve('success')
  , {concurrency: 10}

client = new Client Config.aws_key, Config.aws_secret, 'commercetools-test'

client.list { prefix: 'products/'}
.then (data) ->
  
  suffixes = _.map descriptions[0].formats, (format) ->
    format.suffix
  
  # reject content representing a folder
  files = _.reject data.Contents, (content) ->
    content.Size == 0 || _.find suffixes, (suffix) ->
      content.Key.indexOf(suffix) > 0
    
  # process files
  processImages files
.then (results) ->
  console.log results
.catch (error) ->
  console.log error
