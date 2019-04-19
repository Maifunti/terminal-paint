# frozen_string_literal: true

require 'tty-reader'

module TerminalPaint
  module Display
    class BasicDisplay
      def initialize(input=$stdin, output=$stdout, error=$stderr)
        @reader = TTY::Reader.new input: input, output: output
        @output = output
        @error = error
      end

      def get_user_input(prompt)
        @reader.read_line prompt
      rescue TTY::Reader::InputInterrupt
        nil
      end

      def append_error(string)
        @error.puts string
      end

      def append_output(string)
        @output.puts string
      end

      def refresh
        # no op
      end
    end
  end
end
