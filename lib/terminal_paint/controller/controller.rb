# frozen_string_literal: true

module TerminalPaint
  class Controller
    class Result
      attr_reader :command, :success, :error

      def initialize(command)
        @command = command
      end

      def for_failure(message)
        @success = false
        @err_io = message
        self
      end

      def for_success
        @success = true
        self
      end

      def pretty
        @success ? @command : "#{@command} #{@err_io}"
      end
    end

    attr_reader :painting

    def initialize(interface)
      @call_back_listener = interface
    end

    def scroll(x_del, y_del)
      @call_back_listener.scroll_horizontal(x_del)
      @call_back_listener.scroll_vertical(y_del)
    end

    # @param [String] user_input
    # @return Array<command, result>
    def process_string(user_input)
      command, *arguments = user_input.to_s.strip.split(' ')
      return Result.new('').for_failure("Bad Input: '#{user_input}'") unless command
      command = command.upcase
      pretty_input = [command, arguments].join(' ')
      result = Result.new(pretty_input)

      case command
      when 'C'
        return result.for_failure('Illegal Arguments') unless arguments.size == 2
        return result.for_failure('Size must be an integer') unless arguments.all? { |arg| /^[0-9]+$/.match(arg) }

        width = arguments[0].to_i
        height = arguments[1].to_i

        return result.for_failure('Size must be > 0') if width <= 0 || height <= 0

        @canvas = Canvas.new(width, height)
        @call_back_listener.new_canvas(@canvas)
      when 'L'
        return result.for_failure('First create a new canvas') unless @canvas
        return result.for_failure('Illegal Arguments') unless arguments.size == 4
        unless arguments.all? { |arg| /^[0-9]+$/.match(arg) }
          return result.for_failure('Illegal Arguments. Size must be an integer')
        end

        x1, y1, x2, y2 = *arguments.map(&:to_i)

        if x1 != x2 && y1 != y2
          return result.for_failure("Illegal Arguments. Arguments '#{arguments}' do not specify a straight line")
        end

        Draw::Line.print(@canvas, x1, y1, x2, y2)
      when 'R'
        return result.for_failure('First create a new canvas') unless @canvas
        return result.for_failure('Illegal Arguments') unless arguments.size == 4
        unless arguments.all? { |arg| /^[0-9]+$/.match(arg) }
          return result.for_failure('Illegal Arguments. Size must be an integer')
        end

        x1, y1, x2, y2 = *arguments.map(&:to_i)

        Draw::Rectangle.print(@canvas, x1, y1, x2, y2)
      when 'B'
        return result.for_failure('First create a new canvas') unless @canvas
        return result.for_failure('Illegal Arguments') unless arguments.size == 3
        unless arguments[0..1].all? { |arg| /^[0-9]+$/.match(arg) }
          return result.for_failure('Illegal Arguments. Size must be an integer')
        end

        x, y = *arguments[0..1].map(&:to_i)
        replacement_color = arguments[2]

        Draw::FloodFill.print(@canvas, x, y, replacement_color)
      when 'Q'
        exit
      else
        return result.for_failure('Unknown command')
      end

      result.for_success
    end
  end
end
