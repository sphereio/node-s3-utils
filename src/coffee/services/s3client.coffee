_ = require 'underscore'
path = require 'path'
knox = require 'knox'
Promise = require 'bluebird'
easyimage = require 'easyimage'
ProgressBar = require 'progress'
fs = Promise.promisifyAll require('fs')

class S3Client
  constructor: (opts = {}) ->
    {key, secret, bucket} = opts
    throw new Error 'Missing AWS \'key\'' unless key
    throw new Error 'Missing AWS \'secret\'' unless secret
    throw new Error 'Missing AWS \'bucket\'' unless bucket

    @knoxClient = knox.createClient
      key: key
      secret: secret
      bucket: bucket

    @knoxClient = Promise.promisifyAll @knoxClient

  list: (args) -> @knoxClient.listAsync args

  getFile: (source) -> @knoxClient.getFileAsync source

  putFile: (source, filename, header) -> @knoxClient.putFileAsync source, filename, header

  copyFile: (source, destination) -> @knoxClient.copyFileAsync source, destination

  deleteFile: (file) -> @knoxClient.deleteFileAsync file

  moveFile: (source, destination) ->
    @copyFile source, destination
    .then => @deleteFile source

  _imageKey: (prefix, suffix, extension) -> "#{prefix}#{suffix}#{extension or 'jpg'}"

  resizeAndUploadImage: (image, prefix, formats) ->

    extension = path.extname image
    basename = path.basename image, extension
    basename_full = path.basename image

    tmp_original = "/tmp/#{basename_full}"

    Promise.map formats, (format) =>
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

  resizeAndUploadImages: (images, description) ->

    bar = new ProgressBar "Processing prefix '#{description.prefix}':\t[:bar] :percent, :current of :total images done (time: elapsed :elapseds, eta :etas)", {
      complete: '=',
      incomplete: ' ',
      width: 20,
      total: images.length
    }

    Promise.map images, (image) =>
      @getFile(image.Key)
      .then (response) ->
        name = path.basename(image.Key)
        tmp_resized = "/tmp/#{name}"
        stream = fs.createWriteStream tmp_resized
        new Promise (resolve, reject) ->
          response.pipe stream
          response.on 'end', resolve
          response.on 'error', reject
      .then =>
        @resizeAndUploadImage image.Key, description.prefix, description.formats
      .then (result) =>
        name = path.basename(image.Key)
        source = "#{description.prefix_unprocessed}#{name}"
        target = "#{description.prefix_processed}#{name}"
        @moveFile source, target
      .then ->
        Promise.resolve bar.tick()
    , {concurrency: 1}

module.exports = S3Client
