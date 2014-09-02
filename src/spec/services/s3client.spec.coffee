_ = require 'underscore'
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
    expect(@s3client._knoxClient).toBeDefined()

  _.each ['key', 'secret', 'bucket'], (key) ->
    it "should throw error if no '#{key}' is defined", ->
      opt = _.clone(CREDENTIALS)
      delete opt[key]
      client = -> new S3Client opt
      expect(client).toThrow new Error("Missing AWS '#{key}'")
