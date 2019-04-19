# frozen_string_literal: true

module TerminalPaint
  module View
    class AppChromeView
      HEADER = "Terminal Paint #{TerminalPaint::VERSION}"
      SCROLL_TEXT = ' press <ESC> to end scroll '
      SCROLL_HELP = ' press <ESC> to scroll '

      attr_writer :scroll_text_visibility

      # @param [Display] display
      def render(display)
        top = left = 0
        width = display.width
        height = display.height

        # print border
        Draw::Border.print(display, left, top, (display.width - 1), (display.height - 1), style: :thick)

        # print header text
        header_width = HEADER.size
        start_x = (width - header_width) / 2
        Draw::PaintText.print(display, start_x, 0, HEADER)

        # print footer text
        footer = if @scroll_text_visibility
                   SCROLL_TEXT
                 else
                   SCROLL_HELP
                 end
        Draw::PaintText.print(display, (width - footer.size - 1), (height - 1), footer)
      end

      def get_min_view_size
        [[HEADER, SCROLL_TEXT, SCROLL_HELP].map(&:size).max, 3]
      end
    end
  end
end
