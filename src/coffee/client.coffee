fs = require 'fs'
Q = require 'q'
knox = require 'knox'
_ = require('underscore')._
Upload = require('s3-uploader')
aws = require('aws-sdk')

class Client
  constructor: (key, secret, bucket) ->
    @knoxClient = knox.createClient
      key: key
      secret: secret
      bucket: bucket
      
    @uploaderClient = new Upload bucket,
      awsBucketUrl: "https://s3-eu-west-1.amazonaws.com/#{bucket}/",
      awsBucketPath: "products/",
      awsBucketAcl: 'public-read',
      versions: [
        {
          suffix: '-large',
          quality: 80
          maxHeight: 1040,
          maxWidth: 1040,
        }
        {
          suffix: '-medium',
          maxHeight: 780,
          maxWidth: 780
        }
        {
          suffix: '-small',
          maxHeight: 320,
          maxWidth: 320
        }
      ]

    config =
      accessKeyId: key,
      secretAccessKey: secret
      region: 'eu-west-1'

    @uploaderClient.s3.config.update(config)

  list: (args) ->
    Q.ninvoke @knoxClient, 'list', args

  getFile: (file) ->
    Q.ninvoke @knoxClient, "getFile", file

  upload: (file) ->
    deferred = Q.defer()
    @uploaderClient.upload "/tmp/#{file}", {}, (err, images, meta) ->
      if err
        console.error err
      else
        images.forEach (image) ->
          console.log 'Thumbnail with width %i, height %i, at %s', image.width, image.height, image.url
        deferred.resolve
    deferred.promise

module.exports = Client
