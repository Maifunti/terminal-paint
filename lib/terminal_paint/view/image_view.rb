# frozen_string_literal: true

module TerminalPaint
  module View
    class ImageView
      def initialize
        @scroll_y = @scroll_x = 0
      end

      def set_canvas(canvas)
        @canvas = canvas
        @scroll_y = @scroll_x = 0
      end

      def scroll(x_del, y_del)
        return unless @canvas

        @scroll_x += x_del
        # Don't scroll outside screen
        @scroll_x = 0 if @scroll_x < 0
        @scroll_x = @canvas.width - 1 if @scroll_x > @canvas.width

        @scroll_y += y_del
        @scroll_y = 0 if @scroll_y < 0
        @scroll_y = @canvas.height - 1 if @scroll_y > @canvas.height
      end

      def render(display)
        return unless @canvas

        x_padding = BORDER_AND_PADDING
        y_padding = BORDER_AND_PADDING
        dest_width = display.width - (x_padding * 2)
        dest_height = display.height - (y_padding * 2)

        # If canvas can fit within display, eliminate scroll
        @scroll_x = 0 if @canvas.width < dest_width
        # If canvas can fit within display, eliminate scroll
        @scroll_y = 0 if @canvas.height < dest_height

        source_y = @scroll_y
        dest_y = y_padding
        while source_y < @canvas.height && dest_y <= dest_height
          source_x = @scroll_x
          dest_x = x_padding
          while source_x < @canvas.width && dest_x <= dest_width
            value = @canvas.get_value(source_x, source_y)
            display.set_value(dest_x, dest_y, value)

            source_x += 1
            dest_x += 1
          end
          source_y += 1
          dest_y += 1
        end
      end

      def get_min_view_size
        # the view is scrollable so technically there is no minimum
        [5, 5]
      end
    end
  end
end
