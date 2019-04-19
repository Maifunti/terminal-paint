# frozen_string_literal: true

Encoding.default_external = Encoding::UTF_8
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'simplecov'
SimpleCov.start

require 'terminal_paint'
require 'strings'
require 'support/test_helper.rb'
RSPEC_ROOT = File.dirname(__FILE__)

# Force tty-reader to read from configured input io. \
# TTY::Reader library has a bug in windows environment where it would always defer to windows api libraries for
# retrieving user input instead of the provided input IO. This setting forces it to use the provided input io
ENV['TTY_TEST'] = 'true'

RSpec.configure do |config|
  config.mock_with(:rspec) do |mocks|
    mocks.verify_doubled_constant_names = true
  end

  begin
    require 'curses'
  rescue LoadError
    config.filter_run_excluding(requires_curses: true)
  end
end
