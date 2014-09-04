_ = require 'underscore'
Promise = require 'bluebird'
S3Client = require '../../lib/services/s3client'

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
