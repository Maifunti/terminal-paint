# frozen_string_literal: true

module TerminalPaint
  class Controller
    class Result
      attr_reader :command, :success

      def initialize(command, arguments)
        @command = command || ''
        @arguments = arguments || ''
      end

      def for_failure(message)
        @success = false
        @err_message = message
        self
      end

      def for_success
        @success = true
        self
      end

      def formatted_message
        formmatted_input = [@command, @arguments].join(' ').strip
        if @success
          formmatted_input
        else
          "'#{formmatted_input}' #{@err_message}"
        end
      end

      def exiting?
        @command == 'Q'
      end
    end

    attr_reader :canvas

    def initialize(interface)
      @call_back_listener = interface
    end

    # @param [String] user_input
    # @return [Result]
    def process_string(user_input)
      command, *arguments = user_input.to_s.strip.split(' ')
      return Result.new(nil, nil).for_failure("Bad Input") unless command
      command = command.upcase
      result = Result.new(command, arguments)

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

        coordinates = extract_coordinates(arguments)
        if coordinates.any? { |arg| arg < 0 }
          return result.for_failure('Illegal Arguments. Coordinates must be > 0')
        end

        x1, y1, x2, y2 = *coordinates
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

        coordinates = extract_coordinates(arguments)
        if coordinates.any? { |arg| arg < 0 }
          return result.for_failure('Illegal Arguments. Coordinates must be > 0')
        end

        x1, y1, x2, y2 = *coordinates

        Draw::Rectangle.print(@canvas, x1, y1, x2, y2)
      when 'B'
        return result.for_failure('First create a new canvas') unless @canvas
        return result.for_failure('Illegal Arguments') unless arguments.size == 3
        unless arguments[0..1].all? { |arg| /^[0-9]+$/.match(arg) }
          return result.for_failure('Illegal Arguments. Size must be an integer')
        end

        coordinates = extract_coordinates(arguments[0..1])
        if coordinates.any? { |arg| arg < 0 }
          return result.for_failure('Illegal Arguments. Coordinates must be > 0')
        end

        x, y = *coordinates
        replacement_color = arguments[2]

        Draw::FloodFill.print(@canvas, x, y, replacement_color)
      when 'Q'
        # App will exit
      else
        return result.for_failure('Unknown command')
      end

      result.for_success
    end

    # Our app internally uses a coordinate system with (0,0) as origin.
    # User input uses (1,1) as origin.
    # @returns the adjusted coordinates for internal use
    def extract_coordinates(args)
      args.map(&:to_i).map { |int| int - 1 }
    end
  end
end
