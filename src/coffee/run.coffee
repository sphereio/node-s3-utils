fs = require 'fs'
Q = require 'q'
path = require('path')
_ = require('underscore')._
_s = require 'underscore.string'
Client = require '../lib/client'
Config = require('../config').config

pipeResponse = (response, stream) ->
  deferred = Q.defer()
  response.pipe stream
  response.on 'end', ->
    deferred.resolve "rrr"
  response.on 'error', (error) ->
    deferred.reject new Error(error)
  deferred.promise

createFileFromResponse = (name, response) ->
  stream = fs.createWriteStream "/tmp/#{name}"
  pipeResponse response, stream
  
processImages = (files) ->
  Q.allSettled _.map files, (file) ->
    client.getFile(file.Key)
    .then (response) ->
      name = path.basename(file.Key)
      createFileFromResponse name, response
    .then ->
      name = path.basename(file.Key)
      client.upload name

client = new Client Config.aws_key, Config.aws_secret, 'commercetools-test'

client.list { prefix: 'products/'}
.then (data) ->
  # reject folders
  files = _.reject data.Contents, (content) ->
    content.Size == 0
  # process files
  processImages files
.then (results) ->
  console.log results
  results.forEach (result) ->
    if result.state is 'fulfilled'
      
    else
.fin()
.fail (error) -> done _.prettify error
