_ = require('underscore')._
path = require 'path'
knox = require('knox')
Promise = require 'bluebird'
easyimage = require('easyimage')
fs = Promise.promisifyAll require('fs')
ProgressBar = require 'progress'


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

  resizeAndUploadImage: (file, prefix, formats) ->
    
    Promise.map formats, (format) =>

      extension = path.extname file
      basename = path.basename file, extension
      basename_full = path.basename file
      
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

  resizeAndUploadImages: (files, description) ->

    bar = new ProgressBar "Processing prefix '#{description.headers.prefix}':\t[:bar] :percent, :current of :total images done (time: elapsed :elapseds, eta :etas)", {
      complete: '=',
      incomplete: ' ',
      width: 20,
      total: files.length
    }
    
    Promise.map files, (file) =>
      @getFile(file.Key)
      .then (response) ->
        name = path.basename(file.Key)
        stream = fs.createWriteStream "/tmp/#{name}"
        new Promise (resolve, reject) ->
          response.pipe stream
          response.on 'end', resolve
          response.on 'error', reject
      .then =>
        name = path.basename(file.Key)
        @resizeAndUploadImage file.Key, description.headers.prefix, description.formats
      .then ->
        Promise.resolve bar.tick()
    , {concurrency: 1}
  
module.exports = Client
