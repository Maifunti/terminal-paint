# frozen_string_literal: true

require_relative '../controller/controller.rb'
require_relative '../controller/controller_interface.rb'
require_relative '../display/display_interface.rb'

module TerminalPaint
  class InteractiveApp
    include TerminalPaint::ControllerInterface
    include TerminalPaint::Display::DisplayInterface

    def self.run(display)
      new(display).run
    end

    def initialize(display)
      @display = display
      @controller = Controller.new(self)
      @display.callback_listener = self

      @prompt_view = View::PromptView.new
      @app_chrome_view = View::AppChromeView.new
      @image_view = View::ImageView.new
      @terminal_size_error_view = View::TerminalSizeErrorView.new
    end

    # @overide ControllerInterface
    def new_canvas(canvas)
      @image_view.set_canvas(canvas)
    end

    # @override DisplayInterface
    def screen_resized
      render_views
    end

    # @override DisplayInterface
    def process_string(user_input)
      result = @controller.process_string(user_input)
      @prompt_view.add_history(result)
      @exiting = result.exiting?
    end

    # @override DisplayInterface
    def scroll(x_del, y_del)
      @image_view.scroll(x_del, y_del)
    end

    # @override DisplayInterface
    def set_scroll_mode(scroll_mode)
      @app_chrome_view.scroll_text_visibility = scroll_mode
    end

    # Runs app loop blocking, until stdin reaches EOF; or an interrupt is received
    def run
      loop do
        render_views
        break if @exiting || !@display.process_input_stream
      end
    rescue Interrupt
      # no op. App will close
    ensure
      @display.close
    end

    def render_views
      @display.erase

      min_width = min_height = 0

      min_width, min_height = max_dimension(min_width, min_height, *@app_chrome_view.get_min_view_size)
      min_width, min_height = max_dimension(min_width, min_height, *@image_view.get_min_view_size)
      min_width, min_height = max_dimension(min_width, min_height, *@prompt_view.get_min_view_size)

      if @display.width <= min_width || @display.height <= min_height
        @terminal_size_error_view.set_required_size(min_height, min_height)
        @terminal_size_error_view.render(@display)
      else
        @app_chrome_view.render(@display)
        @image_view.render(@display)
        @prompt_view.render(@display)
        @display.set_prompt_area(*@prompt_view.prompt_area)
      end

      @display.refresh
    end

    def max_dimension(width1, height1, width2, height2)
      [[width1, width2].max, [height1, height2].max]
    end
  end
end
