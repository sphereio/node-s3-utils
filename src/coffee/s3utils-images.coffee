#!/usr/bin/env node
program = require 'commander'

program
.command 'convert', 'Convert images'
.parse process.argv

if !program.runningCommand
  program.outputHelp()
  process.exit 1
