_ = require('underscore')._
path = require 'path'
knox = require('knox')
Promise = require 'bluebird'
easyimage = require('easyimage')
fs = Promise.promisifyAll require('fs')

class Client
  constructor: (key, secret, bucket) ->
    @knoxClient = knox.createClient
      key: key
      secret: secret
      bucket: bucket
    
    @knoxClient = Promise.promisifyAll @knoxClient

  list: (args) ->
    @knoxClient.listAsync args

  getFile: (source) ->
    @knoxClient.getFileAsync source
    
  putFile: (source, filename, header) ->
    @knoxClient.putFileAsync source, filename, header

  _imageKey: (prefix, suffix, extension) ->
    "#{prefix}#{suffix}#{extension || 'jpg'}"

  resizeAndUpload: (source, prefix, formats) ->
    
    Promise.map formats, (format) =>

      extension = path.extname source
      basename = path.basename source, extension
      basename_full = path.basename source
      
      tmp_original = "/tmp/#{basename_full}"
      tmp_resized = @_imageKey "/tmp/#{basename}", format.suffix, extension
      
      easyimage.resize
        src: tmp_original,
        dst: tmp_resized,
        width: format.width,
        height: format.height
      .then (image) =>
        header = 'x-amz-acl': 'public-read'
        aws_content_key = @_imageKey "#{prefix}#{basename}", format.suffix, extension
        @putFile tmp_resized, aws_content_key, header
      .catch (error) ->
    , {concurrency: 2}
      
module.exports = Client
