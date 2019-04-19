# frozen_string_literal: true

require_relative '../controller/controller.rb'
require_relative '../controller/controller_interface.rb'

module TerminalPaint
  class BasicApp
    include TerminalPaint::ControllerInterface

    def self.run(display)
      new(display).run
    end

    def initialize(display)
      @display = display
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
      user_input = @display.get_user_input(PROMPT)
      # display will return false when stdin has an EOF error
      return false if user_input.empty?

      @display.refresh
      result = @controller.process_string(user_input)
      if result.success
        if @canvas
          (0...@canvas.height).each do |y|
            @display.append_output(@canvas.get_line(y).join(''))
          end
        end
      else
        msg = if result.command.chomp.empty?
                "#{APP_USAGE}\n"
              else
                "\n#{result.pretty}\n\n#{APP_USAGE}\n"
              end
        @display.append_error(msg)
      end
      true
    end
  end
end
