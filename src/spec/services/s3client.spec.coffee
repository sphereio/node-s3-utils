_ = require 'underscore'
Promise = require 'bluebird'
S3Client = require '../../lib/services/s3client'
fs = Promise.promisifyAll require('fs')

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
