# frozen_string_literal: true

module TerminalPaint
  module Display
    # Uses curses gem (gnu ncurses) for interacting with the terminal
    # This display adapter is more performant than TTYDisplayAdapter. It requires
    # a native library gem extension which reduces it's portability
    class CursesDisplayAdapter
      require 'curses'
      require_relative 'editor.rb'

      # We're using both curses keypad codes and ascii ctrl characters
      BACKSPACE = [Curses::KEY_BACKSPACE, 8]
      ENTER = [Curses::KEY_ENTER, 13, 10, $INPUT_RECORD_SEPARATOR]
      ESCAPE = [27]
      LEFT = [Curses::KEY_LEFT]
      RIGHT = [Curses::KEY_RIGHT]
      DOWN = [Curses::KEY_DOWN]
      UP = [Curses::KEY_UP]

      # Callers must call #close when finished
      def initialize
        Curses.init_screen
        Curses.cbreak
        Curses.noecho

        @editor = Editor.new(self)
        initialize_window
      end

      def width
        # leave a space for the new line character otherwise text will overflow on windows consoles
        @nb_cols - 1
      end

      def height
        @nb_lines
      end

      # @param [DisplayInterface]
      def callback_listener=(interface)
        @call_back_listener = interface
      end

      # @param [Integer] x column
      # @param [Integer] y row
      # @param [String] value can be a multi line string
      def set_value(x, y, value)
        return unless value
        return if y >= height

        value.lines.each_with_index do |line, row_index|
          break if y + row_index > height
          next if line.empty?
          line_buffer = @display_buffer[y + row_index]

          # clamp string to be within window dimensions to prevent overflow
          clamped_value = line.slice(0, [line.size, width - x].min)
          next if clamped_value.nil?
          clamped_value.each_char.with_index do |char, index|
            raise if index + x >= width
            line_buffer[(x + index)] = char
          end
        end
      end

      # @param [Integer] x column
      # @param [Integer] y row
      def set_pos(x, y)
        @main_window.setpos(y, x)
      end

      def set_prompt_area(x, y, width)
        @editor.set_prompt_area(x, y, width)
      end

      def erase
        @main_window.erase
        @display_buffer.each(&:clear)
      end

      def refresh
        display_string = @display_buffer.map do |line|
          line.map { |char| char || ' ' }.join('')
        end.join($INPUT_RECORD_SEPARATOR)
        @main_window.setpos(0, 0)
        @main_window.addstr(display_string)
        @main_window.refresh
      end

      def close
        Curses.close_screen
      end

      def process_input_stream
        code = getch

        case code
        when Curses::KEY_RESIZE
          initialize_window
          @call_back_listener.screen_resized
        when *ESCAPE
          toggle_movement_mode
        when *ENTER
          unless @scroll_mode
            # next if @scroll_mode
            @call_back_listener.process_string(@editor.pop_input)
          end
        when *BACKSPACE
          @editor.backspace unless @scroll_mode
        when *LEFT
          move(:horizontal, -1)
        when *RIGHT
          move(:horizontal, 1)
        when *DOWN
          move(:vertical, 1)
        when *UP
          move(:vertical, -1)
        when /[ -~]/ # matches all printable ascii characters
          @editor.append(code) unless @scroll_mode
        when nil
          # nil is returned when input stream EOF has been reached
          return false
        else
          # noop
        end
        true
      end

      private

      def initialize_window
        @main_window&.close
        Curses.refresh
        @main_window = Curses::Window.new(0, 0, 0, 0)
        # use keypad mode so curses can convert control escape sequences to curses keypad codes
        @main_window.keypad(true)
        @nb_cols = @main_window.maxx
        @nb_lines = @main_window.maxy
        @editor.window = @main_window
        @display_buffer = Array.new(height) { Array.new(width) }
      end

      def toggle_movement_mode
        @scroll_mode = !@scroll_mode
        @call_back_listener.set_scroll_mode(@scroll_mode)
        # change cursor visibility
        if @scroll_mode
          Curses.curs_set(0)
        else
          Curses.curs_set(2)
        end
      end

      def move(orientation, by)
        if @scroll_mode
          x_del = orientation == :horizontal ? by : 0
          y_del = orientation == :vertical ? by : 0
          @call_back_listener.scroll(x_del, y_del)
        else
          # internal scrolling of editor
          if orientation == :horizontal
            @editor.move(by)
          end
        end
      end

      def getch
        @main_window.getch
      rescue EOFError
        nil
      end
    end
  end
end
