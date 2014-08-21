fs = require 'fs'
Q = require 'q'
knox = require 'knox'
_ = require('underscore')._

class Client
  constructor: (key, secret, bucket) ->
    @client = knox.createClient
      key: key
      secret: secret
      bucket: bucket

  list: (args) ->
    Q.ninvoke @client, 'list', args

  getFile: (file) ->
    Q.ninvoke @client, "getFile", file

module.exports = Client
