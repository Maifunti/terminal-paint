# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'terminal_paint/version'

Gem::Specification.new do |spec|
  spec.name = "terminal-paint"
  spec.date = '2019-04-07'
  spec.version = TerminalPaint::VERSION
  spec.authors = ["Yakubu Lamay"]
  spec.email = ["yakubu.lamay@outlook.com"]

  spec.summary = 'Terminal Paint'
  spec.description = 'Terminal Paint'
  spec.license = "MIT"

  spec.files += Dir.glob("lib/**/*")
  spec.executables = ['terminal-paint']
  spec.require_paths = ["lib"]

  # this dependency is optional
  # spec.add_dependency('curses', '1.2.7')
  spec.add_dependency('tty-cursor', '~>0.6')
  spec.add_dependency('tty-reader', '~>0.5')
  spec.add_dependency('tty-screen', '~>0.6')
end
