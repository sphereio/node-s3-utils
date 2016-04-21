_ = require 'underscore'
Promise = require 'bluebird'
Compress = require '../lib/compress'
fs = Promise.promisifyAll require('fs')

examplesFolder = "" + __dirname + "/../examples/"
compressedFolder = examplesFolder + "compressed/"
describe 'Compress', ->

  beforeEach ->
    try
      fs.mkdirSync compressedFolder
    catch e
      if e.code != 'EEXIST'
        throw e

  afterEach ->
    fs.rmdirSync compressedFolder

  _.each [
    "darthMeow.jpg"
    "saberCat.gif"
    "stormtroopocat.png"
    "git-cat.svg"
    "productImage.jpg"
  ], (fileName) ->
    it "should compress file (#{fileName})", (done) ->
      extension = fileName.substr(fileName.length - 3)
      sourcePath = examplesFolder + fileName
      destinationPath = compressedFolder + fileName
      ext = Compress.compressImage sourcePath, compressedFolder, extension
      .then (result) ->
        expect(result).toBe(true)
        fileSizeInBytesBeforeCompressing = fs.statSync(sourcePath)["size"]
        fileSizeInBytesAfterCompressing = fs.statSync(destinationPath)["size"]
        expect(fileSizeInBytesBeforeCompressing).not.toBeLessThan(fileSizeInBytesAfterCompressing)
        fs.unlinkAsync destinationPath
      .then -> done()
      .catch (error) -> done(error)
