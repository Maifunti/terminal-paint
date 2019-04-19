# frozen_string_literal: true

require PROJECT_ROOT + '/terminal_paint/display/tty_display_adapter.rb'

# allows us to provide input and capture stdout when using curses library
module Test
  class TTYDisplayAdapter < TerminalPaint::Display::TTYDisplayAdapter
    def self.build(width, height, stdin, stdout)
      new(width, height, stdin, stdout)
    end

    def initialize(width, height, stdin, stdout)
      # Force tty-reader to read from configured input io. \
      # TTY::Reader library has a bug in windows environment where it would always defer to windows api libraries for
      # retrieving user input instead of the provided input IO. This setting forces it to use the provided input io
      ENV['TTY_TEST'] = 'true'
      set_test_display_dimensions(width, height)
      super(stdin, stdout)
    end

    # @overide
    def width
      @test_display_width
    end

    # @overide
    def height
      @test_display_height
    end

    ############### test methods

    def get_captured_output
      @old_buffer.map do |line|
        line.map { |char| char || ' ' }.join('')
      end.join($INPUT_RECORD_SEPARATOR)
    end

    def set_test_display_dimensions(width, height)
      @test_display_width = width
      @test_display_height = height
    end
  end
end
