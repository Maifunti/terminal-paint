# frozen_string_literal: true

module TerminalPaint
  module Display
    # Uses manual manipulation of the terminal using IO print commands, ANSI escape, and ASCII control codes
    # This solution is less performant than CursesDisplayAdapter but does not require a native gem extension
    class TTYDisplayAdapter
      require 'tty-cursor'
      require 'tty-screen'
      require 'io/console'
      require_relative 'editor.rb'
      require_relative '../os.rb'

      CSI = "\e[".freeze
      ENABLE_ALTERNATE_BUFFER = CSI + "?1049h"
      DISABLE_ALTERNATE_BUFFER = CSI + "?1049l"
      DISABLE_LINE_WRAP = CSI + "7l"
      ENABLE_LINE_WRAP = CSI + "7h"

      # TTY::Reader we're using will return ANSI escape codes or ASCII control codes
      BACKSPACE = ["\u007F", "\b"]
      ENTER = ["\r", "\n"]
      ESCAPE = ["\e", 27]
      LEFT = ["\e[D", "\u00E0K"]
      RIGHT = ["\e[C", "\u00E0M"]
      DOWN = ["\e[B", "\u00E0P"]
      UP = ["\e[A", "\u00E0H"]

      # Callers must call #close when finished
      def initialize(input, output)
        @input = input || $stdin
        @output = output || $stdout

        @reader = TTY::Reader.new input: @input, output: @output, interrupt: :exit, track_history: false

        initialize_screen

        @editor = Editor.new self

        # try to trap terminal resizes. Only works on systems that support SIGWINCH signal
        begin
          @original_handler = trap('SIGWINCH') do
            Thread.current[:screen_size_dirty] = true
          end
        rescue ArgumentError
          # no-op signwinch is not supported
        end

        if TerminalPaint::OS.win?
          # enable win console support for Console Virtual Terminal Sequences
          require_relative '../win_api.rb'
          @win_api = TerminalPaint::WinApi.new
          @win_api.enable_virtual_terminal_processing
        end
        @output.print ENABLE_ALTERNATE_BUFFER
        @output.print DISABLE_LINE_WRAP
      end

      def initialize_screen
        @width = TTY::Screen.width
        @height = TTY::Screen.height
        @new_buffer = Array.new(height) { Array.new(width) }
        @old_buffer = Array.new(height) { Array.new(width) }
      end

      def width
        # leave a space for the new line character otherwise text will overflow on windows consoles
        @width - 1
      end

      def height
        @height
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

        value.to_s.lines.each do |line|
          # clamp string to be within window dimensions to prevent overflow
          clamped_value = line.slice(0, [line.size, width - x].min).to_s
          clamped_value.each_char.with_index do |char, index|
            fail if index + x >= width
            line = @new_buffer[y]
            line[(x + index)] = char
          end
        end
      end

      # @param [Integer] x column
      # @param [Integer] y row
      # set the position of the cursor
      def set_pos(x, y)
        @output.print TTY::Cursor.move_to(x, y)
      end

      def set_prompt_area(x, y, width)
        @editor.set_prompt_area x, y, width
      end

      def erase
        @new_buffer.each { |line_array| line_array.clear }
      end

      # reduces stuttering while typing by only refreshing the changed cells on the display
      # moving the display cursor and printing to terminal is an expensive operation.
      # This avoids us having to print out the whole screen when only a single character may have changed
      def efficient_refresh
        @refreshes ||= 0
        @refreshes += 1

        changes = 0

        @new_buffer.each_with_index do |line, row_index|
          @output.print TTY::Cursor.move_to(0, row_index)
          cursor_index = 0
          line.each_with_index do |char, col_index|
            if char != @old_buffer[row_index][col_index]
              changes += 1
              if changes > 5
                return false
              end
              cursor_del = col_index - cursor_index
              if cursor_del > 0
                @output.print TTY::Cursor.move(cursor_del, 0)
              end
              @output.print(char || ' ') # treat nil as empty space
              cursor_index = col_index + 1
            end
          end
        end
        true
      end

      def refresh
        @output.print TTY::Cursor.save

        unless efficient_refresh
          @output.print TTY::Cursor.move_to(0, 0)
          @output.print TTY::Cursor.clear_screen
          display_string = @new_buffer.map do |line|
            line.map { |char| char || ' ' }.join('')
          end.join("\n")

          @output.print display_string
        end
        @output.flush
        @output.print TTY::Cursor.restore

        # clear old buffer and re-use as the new display buffer
        recycled_buffer = @old_buffer
        recycled_buffer.each { |line_array| line_array.clear }
        @old_buffer = @new_buffer
        @new_buffer = recycled_buffer
      end

      def close
        trap('SIGWINCH', @original_handler) if @original_handler
        @output.print DISABLE_ALTERNATE_BUFFER
        @win_api.restore if @win_api
      end

      def process_input_stream
        if Thread.current[:screen_size_dirty]
          Thread.current[:screen_size_dirty] = false
          initialize_screen
          @call_back_listener.screen_resized
        end

        char = getch

        case char
        when *ESCAPE
          toggle_movement_mode
        when *ENTER
          unless @scroll_mode
            # next if @scroll_mode
            @call_back_listener.process_string @editor.pop_input
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
        when /^[ -~]$/ # matches all printable ascii characters
          @editor.append char unless @scroll_mode
        when nil
          # nil is returned when input stream EOF has been reached
          return false
        else
          # noop
        end
        return true
      end

      private

      def toggle_movement_mode
        @scroll_mode = !@scroll_mode
        @call_back_listener.set_scroll_mode(@scroll_mode)
        # change cursor visibility
        if @scroll_mode
          @output.print TTY::Cursor.hide
        else
          @output.print TTY::Cursor.show
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
            @editor.move by
          end
        end
      end

      def getch
        @reader.read_keypress(echo: false, raw: true)
      end
    end
  end
end
