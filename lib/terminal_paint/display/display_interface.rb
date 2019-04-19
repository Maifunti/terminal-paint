# frozen_string_literal: true

module TerminalPaint
  module Display
    module DisplayInterface
      def screen_resized(); end

      def process_string(user_input); end

      def scroll(x_del, y_del); end

      def set_scroll_mode(mode); end
    end
  end
end
