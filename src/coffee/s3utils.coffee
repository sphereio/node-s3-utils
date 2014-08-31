#!/usr/bin/env node

program = require 'commander'
pkginfo = require('pkginfo')(module, 'version')

program
.version module.exports.version
.command 'images', 'Image commands'
.parse process.argv
