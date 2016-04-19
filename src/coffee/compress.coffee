debug = require('debug')('s3utils-compress')
Promise = require 'bluebird'
fs = Promise.promisifyAll require('fs')
imagemin = require('imagemin')
_ = require 'underscore'

###*
 * Compress images with basic configuration from Imagemin librabry
###
class Compress

  @compressImage: (source, destination, extension) ->
    new Promise (resolve) ->
      debug 'Compressing image from path: %s', source
      switch extension
        when "png" then plugin = imagemin.optipng({optimizationLevel: 3})
        when "gif" then plugin = imagemin.gifsicle({interlaced: true})
        when "svg" then plugin = imagemin.svgo()
        else plugin = imagemin.jpegtran({progressive: true})

      fs.stat source, (err, stat) ->
        if err == null
          (new imagemin)
            .src(source)
            .dest(destination)
            .use(plugin)
            .run (err) ->
              if err
                resolve 'Cannot compress file: %s', err
              else
                resolve true
        else
          debug 'Cannot compress file: %s', err
          resolve 'Cannot compress file: %s', err

module.exports = Compress
