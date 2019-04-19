# frozen_string_literal: true

module TerminalPaint
  class Canvas
    attr_reader :width, :height

    def initialize(width, height)
      raise if width < 1 || height < 1
      @width = width
      @height = height
      @data = Array.new(height) { Array.new(width) { ' ' } }
    end

    def get_line(y)
      @data[y]
    end

    def get_value(x, y)
      raise if x >= @width || y >= @height
      @data[y][x]
    end

    def set_value(x, y, color)
      return if outside?(x, y)
      raise if color.to_s.length > 1
      @data[y][x] = color
    end

    def inside?(x, y)
      (0...width).cover?(x) && (0...height).cover?(y)
    end

    def outside?(x, y)
      !inside?(x, y)
    end
  end
end
