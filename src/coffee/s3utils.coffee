debug = require('debug')('s3utils')
program = require 'commander'
pkginfo = require('pkginfo')(module, 'version')

program
.version module.exports.version
.command 'files', 'File commands'
.command 'images', 'Image commands'
.parse process.argv

program.on '--help', ->
  console.log "      ____       __                             __         ___  "
  console.log "     /\\  _`\\   /'__`\\                          /\\ \\__  __ /\\_ \\  "
  console.log "     \\ \\,\\L\\_\\/\\_\\L\\ \\                   __  __\\ \\ ,_\\/\\_\\\\//\\ \\     ____  "
  console.log "      \\/_\\__ \\\\/_/_\\_<_      _______    /\\ \\/\\ \\\\ \\ \\/\\/\\ \\ \\ \\ \\   /',__\\  "
  console.log "        /\\ \\L\\ \\/\\ \\L\\ \\    /\\______\\   \\ \\ \\_\\ \\\\ \\ \\_\\ \\ \\ \\_\\ \\_/\\__, `\\  "
  console.log "        \\ `\\____\\ \\____/    \\/______/    \\ \\____/ \\ \\__\\\\ \\_\\/\\____\\/\\____/  "
  console.log "         \\/_____/\\/___/                   \\/___/   \\/__/ \\/_/\\/____/\\/___/  "


debug 'parsing args: %s', process.argv

program.help() unless program.args.length
