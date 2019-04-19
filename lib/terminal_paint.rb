# frozen_string_literal: true

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

module TerminalPaint
  DRAW_CHAR = 'x'
  BORDER_AND_PADDING = 1
  COMMAND_LINE_USAGE = <<~QUOTE
    \n\nUSAGE\n\n
    terminal_paint --ncurses launches interactive terminal app using ncurses library as app display driver. Requires the presence of the "curses" gem
    terminal_paint --tty-cursor launches interactive terminal app using tty-cursor as app display driver
    terminal_paint --basic basic non-interactive REPL app\n\n
  QUOTE
  CURSES_DRIVER_USAGE = <<~QUOTE
    \n\nThis driver requires the curses gem which utilizes gem native C extensions. 
    To use this driver you must first install the curses gem. Run 'gem install curses'
  QUOTE
  APP_USAGE = <<~QUOTE
    Command         Description

    C w h           Creates a new canvas of width w and height h.
    L x1 y1 x2 y2   Create a new line from (x1,y1) to (x2,y2). Currently only
                    horizontal or vertical lines are supported. Horizontal and vertical lines
                    will be drawn using the 'x' character.
    R x1 y1 x2 y2   Create a new rectangle, whose upper left corner is (x1,y1) and
                    lower right corner is (x2,y2). Horizontal and vertical lines will be drawn
                    using the 'x' character.
    B x y c         Fills the entire area connected to (x,y) with "colour" c.
    Q               Quit

  QUOTE
  PROMPT = "> "

  def self.launch(arg)
    case arg
    when '--ncurses'
      begin
        require 'curses'
      rescue LoadError
      end

      if defined?(Curses)
        require_relative 'terminal_paint/display/curses_display_adapter.rb'
        InteractiveApp.run(Display::CursesDisplayAdapter.new)
      else
        puts CURSES_DRIVER_USAGE
        puts COMMAND_LINE_USAGE
      end
    when '--tty-cursor'
      require_relative 'terminal_paint/display/tty_display_adapter.rb'
      InteractiveApp.run(Display::TTYDisplayAdapter.new(IO.new(1), $stdout))
    when '--basic', nil
      require_relative 'terminal_paint/display/basic_display_adapter.rb'
      BasicApp.run(Display::BasicDisplay.new)
    else
      puts COMMAND_LINE_USAGE
    end
  rescue => e
    puts "A fatal exception has occurred"
    $stderr.puts e.full_message
  end
end

require 'pathname'

PROJECT_ROOT = File.dirname(File.absolute_path(__FILE__))
Dir.glob(PROJECT_ROOT + '/terminal_paint/**/*.rb') do |file|
  # load all files except display and win_api files
  next if /\/terminal_paint\/display|win_api/.match file
  require file
end
