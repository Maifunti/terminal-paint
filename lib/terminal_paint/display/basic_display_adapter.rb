# frozen_string_literal: true
module TerminalPaint
  module Display
    class BasicDisplay
      def initialize
        @prompt = TTY::Prompt.new
      end

      # @raises TTY::Reader::InputInterrupt
      def get_user_input(prompt)
        @prompt.ask prompt
      end

      def append_error(string)
        $stderr.puts string
      end

      def append_output(string)
        $stdout.puts string
      end

      def refresh
        # no op
      end
    end
  end
end
