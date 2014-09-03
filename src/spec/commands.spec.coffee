Promise = require 'bluebird'
execAsync = Promise.promisify(require('child_process').exec)

CMD_PATH = "#{__dirname}/../bin/s3utils"

describe 's3utils', ->

  it 'should show help', (done) ->
    execAsync CMD_PATH
    .then (result) ->
      expect(result).toMatch /Usage\: s3utils \[options\] \[command\]/
      done()
    .catch (e) -> done(e)


  describe ':: files', ->

    it 'should show help', (done) ->
      execAsync "#{CMD_PATH} files"
      .then (result) ->
        expect(result).toMatch /Usage\: s3utils-files \[options\] \[command\]/
        done()
      .catch (e) -> done(e)

    describe ':: list', ->

      it 'should show help', (done) ->
        execAsync "#{CMD_PATH} files list"
        .then (result) ->
          expect(result).toMatch /Missing required arguments/
          expect(result).toMatch /Usage\: s3utils-files-list \[options\]/
          done()
        .catch (e) -> done(e)

    describe ':: delete', ->

      it 'should show help', (done) ->
        execAsync "#{CMD_PATH} files delete"
        .then (result) ->
          expect(result).toMatch /Missing required arguments/
          expect(result).toMatch /Usage\: s3utils-files-delete \[options\]/
          done()
        .catch (e) -> done(e)

    describe ':: upload', ->

      it 'should show help', (done) ->
        execAsync "#{CMD_PATH} files upload"
        .then (result) ->
          expect(result).toMatch /Missing required arguments/
          expect(result).toMatch /Usage\: s3utils-files-upload \[options\]/
          done()
        .catch (e) -> done(e)


  describe ':: images', ->

    it 'should show help', (done) ->
      execAsync "#{CMD_PATH} images"
      .then (result) ->
        expect(result).toMatch /Usage\: s3utils-images \[options\] \[command\]/
        done()
      .catch (e) -> done(e)

    describe ':: convert', ->

      it 'should show help', (done) ->
        execAsync "#{CMD_PATH} images convert"
        .then (result) ->
          expect(result).toMatch /Missing required arguments/
          expect(result).toMatch /Usage\: s3utils-images-convert \[options\]/
          done()
        .catch (e) -> done(e)
