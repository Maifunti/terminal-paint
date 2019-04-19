# frozen_string_literal: true

module TerminalPaint
  module View
    class PromptView
      DISPLAYED_HISTORY_COUNT = 3
      # maximum width of displayed text in this view
      MAX_WIDTH = (APP_USAGE.lines + PROMPT.lines).map(&:size).max
      # maximum height of displayed text in this view
      MAX_HEIGHT = (APP_USAGE.lines + PROMPT.lines).size + DISPLAYED_HISTORY_COUNT
      INTERNAL_PADDING = 2

      def initialize
        @history = []
      end

      def add_history(result)
        @history << result
      end

      # @return The area of canvas that should be used for user input
      def prompt_area
        [@prompt_x, @prompt_y, @prompt_width]
      end

      # @param [Display] display
      def render(display)
        # View is aligned to bottom right of screen
        bottom = display.height - BORDER_AND_PADDING - 1
        right = display.width - BORDER_AND_PADDING - 1
        left = right - (MAX_WIDTH + (INTERNAL_PADDING * 2))

        if @history.empty? || @history.last.success
          history_text = @history.last(DISPLAYED_HISTORY_COUNT).map do |result|
            text = (' ' * PROMPT.length) + result.pretty
            # clamp text to be within the width of this view
            text.slice(0, (right - left - (INTERNAL_PADDING * 2)))
          end
          prompt_text = history_text.append(PROMPT).join($INPUT_RECORD_SEPARATOR)
        else
          # special text when last command was an error
          prompt_text = APP_USAGE + PROMPT
        end

        top = bottom - prompt_text.lines.size - (INTERNAL_PADDING * 2)

        # y coordinate start of prompt input. starts at the row of the last line of prompt text
        @prompt_y = top + INTERNAL_PADDING + prompt_text.lines.size - 1
        # x coordinate start of prompt input area
        @prompt_x = left + INTERNAL_PADDING + PROMPT.length
        @prompt_width = right - @prompt_x - 1

        # Clear the canvas
        Draw::SolidRectangle.print(display, left, top, right, bottom, char: ' ')

        Draw::Border.print(display, left, top, right, bottom, style: :light)

        Draw::PaintText.print(display, left + INTERNAL_PADDING, top + INTERNAL_PADDING, prompt_text)
      end

      def get_min_view_size
        [(MAX_WIDTH + INTERNAL_PADDING * 2 + BORDER_AND_PADDING),
         (MAX_HEIGHT + INTERNAL_PADDING * 2 + BORDER_AND_PADDING)]
      end
    end
  end
end
