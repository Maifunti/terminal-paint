# frozen_string_literal: true

module TerminalPaint::Draw
  class PaintText
    extend TerminalPaint::Draw

    def self.print(canvas, x, y, text)
      raise(ArgumentError, 'Canvas must be non null') unless canvas
      assert_integer(x, y)
      assert_positive(x, y)

      text.to_s.split($INPUT_RECORD_SEPARATOR).each_with_index do |line, line_index|
        line.each_char.with_index do |char, col_index|
          canvas.set_value(x + col_index, y + line_index, char)
        end
      end
    end
  end
end
