# frozen_string_literal: true

module TerminalPaint
  module View
    class TerminalSizeErrorView
      TEXT = "Your terminal size %{display_width}x%{display_height} is smaller than the minimum required"\
" %{required_width}x%{required_height}. Please resize your terminal or use terminal_paint --basic"

      attr_writer :scroll_text_visibility

      def set_required_size(required_width, required_height)
        @required_width = required_width
        @required_height = required_height
      end

      # @param [Display] display
      def render(display)
        text = format(TEXT, display_width: display.width, display_height: display.height, required_width: @required_width, required_height: @required_height)
        Draw::PaintText.print(display, 0, 0, text)
      end
    end
  end
end
