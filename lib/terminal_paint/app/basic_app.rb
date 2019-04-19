# frozen_string_literal: true

require_relative '../controller/controller.rb'
require_relative '../controller/controller_interface.rb'

module TerminalPaint
  class BasicApp
    include TerminalPaint::ControllerInterface

    require 'tty/prompt'

    def self.run(console = TTY::Prompt.new)
      new(console).run
    end

    def initialize(console = TTY::Prompt.new)
      @console = console
      @controller = Controller.new(self)
    end

    # @overide
    def new_canvas(canvas)
      @canvas = canvas
    end

    # Runs app loop blocking, until stdin reaches EOF; or an interrupt is received
    def run
      loop do
        break unless app_loop
      end
    end

    def app_loop
      begin
        user_input = @console.get_user_input(PROMPT)
      rescue TTY::Reader::InputInterrupt, EOFError
        return false
      end

      @console.refresh
      result = @controller.process_string(user_input)
      if result.success
        if @canvas
          (0...@canvas.height).each do |y|
            @console.append_output @canvas.get_line(y).join('')
          end
        end
      else
        @console.append_error "#{result.pretty}\n\n#{APP_USAGE}\n"
      end
      true
    end
  end
end
