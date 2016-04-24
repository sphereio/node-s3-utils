_ = require 'underscore'
Promise = require 'bluebird'
S3Client = require '../../lib/services/s3client'
Compress = require '../../lib/compress'
fs = Promise.promisifyAll require('fs')
easyimage = require 'easyimage'

CREDENTIALS =
  key: '1111111'
  secret: '3333333'
  bucket: 's3-bucket-name'

describe 'S3Client', ->

  beforeEach ->
    @s3client = new S3Client CREDENTIALS

  it 'should initialize with credentials', ->
    expect(@s3client).toBeDefined()
    expect(@s3client._ee).toBeDefined()
    expect(@s3client._knoxClient).toBeDefined()

  _.each ['key', 'secret', 'bucket'], (key) ->
    it "should throw error if no '#{key}' is defined", ->
      opt = _.clone(CREDENTIALS)
      delete opt[key]
      client = -> new S3Client opt
      expect(client).toThrow new Error("Missing AWS '#{key}'")

  it 'should use event emitter', (done) ->
    @s3client.on 'foo', (foo) ->
      expect(foo).toBe 'bar'
      done()
    @s3client.emit 'foo', 'bar'

  describe ':: list', ->

    it 'should call underlying function', ->
      spyOn(@s3client._knoxClient, 'listAsync')
      @s3client.list prefix: 'foo'
      expect(@s3client._knoxClient.listAsync).toHaveBeenCalledWith prefix: 'foo'

  describe ':: filteredList', ->

    beforeEach ->
      spyOn(@s3client._knoxClient, 'listAsync').andReturn new Promise (resolve, reject) ->
        resolve
          Contents: [{Size: 1, Key: 'foo'}, {Size: 0, Key: 'bar'}]

    it 'should filter list without folders', (done) ->
      @s3client.filteredList prefix: 'foo', null, true
      .then (filtered) ->
        expect(filtered.length).toBe 1
        expect(filtered[0].Key).toBe 'foo'
        done()
      .catch (err) -> done(err)

    it 'should filter list with folders', (done) ->
      @s3client.filteredList prefix: 'foo', null, false
      .then (filtered) ->
        expect(filtered.length).toBe 2
        expect(filtered[0].Key).toBe 'foo'
        expect(filtered[1].Key).toBe 'bar'
        done()
      .catch (err) -> done(err)

    it 'should filter list with regex', (done) ->
      @s3client.filteredList prefix: 'foo', 'f(\\w)+o', false
      .then (filtered) ->
        expect(filtered.length).toBe 1
        expect(filtered[0].Key).toBe 'foo'
        done()
      .catch (err) -> done(err)

  describe ':: getFile', ->

    it 'should call underlying function', ->
      spyOn(@s3client._knoxClient, 'getFileAsync')
      @s3client.getFile 'foo'
      expect(@s3client._knoxClient.getFileAsync).toHaveBeenCalledWith 'foo'

  describe ':: putFile', ->

    it 'should call underlying function', ->
      spyOn(@s3client._knoxClient, 'putFile').andReturn {on: -> } #noop
      @s3client.putFile 'foo', 'bar', {}
      expect(@s3client._knoxClient.putFile).toHaveBeenCalledWith 'foo', 'bar', {}, jasmine.any(Function)

  describe ':: putDir', ->

    it 'should call underlying function', (done) ->
      spyOn(@s3client, 'putFile').andCallFake -> new Promise (resolve, reject) -> resolve()
      @s3client.putDir "#{__dirname}/../../examples", 'dest/examples', {}
      .then =>
        expect(@s3client.putFile.calls[0].args).toEqual ["#{__dirname}/../../examples/darthMeow.jpg", 'dest/examples/darthMeow.jpg', {}]
        expect(@s3client.putFile.calls[1].args).toEqual ["#{__dirname}/../../examples/descriptions.json", 'dest/examples/descriptions.json', {}]
        done()
      .catch (err) -> done(err)

  describe ':: copyFile', ->

    it 'should call underlying function', ->
      spyOn(@s3client._knoxClient, 'copyFileAsync')
      @s3client.copyFile 'foo', 'bar'
      expect(@s3client._knoxClient.copyFileAsync).toHaveBeenCalledWith 'foo', 'bar'

  describe ':: resizeCompressAndUploadImages', ->

    path = "" + __dirname + "/../../examples"
    source = path + "/productImage.jpg"
    destination = path + "/productImage2.jpg"
    filesList = [{Size: 1, Key: 'foo'}]
    description =
      "prefix": "products/"
      "formats": [
        "suffix": "_thumbnail"
        "width": 240
        "height": 240
      ]

    beforeEach ->
      easyimagePromise = easyimage.resize
        src: source
        dst: destination
        width: 200
      spyOn(easyimage, 'resize').andCallFake -> easyimagePromise

    afterEach ->
      fs.unlinkAsync path + "/foo"
      fs.unlinkAsync destination

    it 'should call compress function', (done) ->
      description["compress"] = true
      spyOn(Compress, 'compressImage')
      spyOn(@s3client, 'putFile').andCallFake -> new Promise (resolve, reject) -> resolve()
      @s3client.resizeCompressAndUploadImages filesList, description, path
      .then ->
        expect(Compress.compressImage).toHaveBeenCalled()
      .then -> done()
      .catch (err) -> done(err)

    it 'shouldn\'t call compress function with wrong parameter', (done) ->
      description["compress"] = "darthmeow"
      spyOn(Compress, 'compressImage')
      spyOn(@s3client, 'putFile').andCallFake -> new Promise (resolve, reject) -> resolve()
      @s3client.resizeCompressAndUploadImages filesList, description, path
      .then ->
        expect(Compress.compressImage).not.toHaveBeenCalled()
      .then -> done()
      .catch (err) -> done(err)

    it 'should call put function with cache-control header', (done) ->
      description["headers_resource"] = "Cache-Control": "max-age=42"
      spyOn(@s3client, 'putFile')
      @s3client.resizeCompressAndUploadImages filesList, description, path
      .then =>
        expect(@s3client.putFile).toHaveBeenCalledWith path + '/foo_thumbnailjpg', 'products/foo_thumbnailjpg',
          {'x-amz-acl': 'public-read', 'Cache-Control': 'max-age=42'}
      .then -> done()
      .catch (err) -> done(err)

