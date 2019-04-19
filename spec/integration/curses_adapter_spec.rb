# frozen_string_literal: true

require 'spec_helper'

describe 'Interactive app using CursesDisplayAdapter', :requires_curses do
  before(:all) { require 'support/test_cursor_display' }

  def simulate_input(string = nil)
    if string
      old_input_pos = test_display.test_input_io.pos
      test_display.test_input_io << string
      test_display.test_input_io.pos = old_input_pos
    end

    # run test
    subject.call

    test_display.get_captured_output
  end

  let(:display_width) { 100 }
  let(:display_height) { 100 }
  let(:test_display) { Test::CursesDisplay.build(display_width, display_height) }
  let(:test_app) { TerminalPaint::InteractiveApp.new(test_display) }

  after { Curses.close_screen }

  subject { -> { test_app.run } }

  Dir.glob(RSPEC_ROOT + "/fixtures/interactive_app/*") do |test_fixture|
    it File.basename(test_fixture).to_s do
      command_text = File.open(RSPEC_ROOT + '/fixtures/integration/' + File.basename(test_fixture) + '/command.txt').read
      expectation_text = File.open(test_fixture + '/expectation.txt').read
      stdout = simulate_input(command_text)

      expect(stdout).to(eql(expectation_text))
    end
  end

  it "can scroll" do
    command_text = File.open(RSPEC_ROOT + '/fixtures/scrolling/command.txt').read
    simulate_input command_text

    base_expectation = File.open(RSPEC_ROOT + '/fixtures/scrolling/expectation.txt').read

    test_app.scroll(150, 150)
    test_app.run # refresh display
    expect(test_display.get_captured_output).to(eq(base_expectation))

    test_app.scroll(20, 0)
    test_app.run
    scroll_horizontal_1 = File.open(RSPEC_ROOT + '/fixtures/scrolling/scroll_horizontal.txt').read
    expect(test_display.get_captured_output).to(eq(scroll_horizontal_1))

    test_app.scroll(-20, 0)
    test_app.run
    expect(test_display.get_captured_output).to(eq(base_expectation))

    test_app.scroll(0, 20)
    test_app.run
    scroll_vertical_1 = File.open(RSPEC_ROOT + '/fixtures/scrolling/scroll_vertical.txt').read
    expect(test_display.get_captured_output).to(eq(scroll_vertical_1))

    test_app.scroll(0, -20)
    test_app.run
    expect(test_display.get_captured_output).to(eq(base_expectation))
  end

  context 'small screen' do
    let(:display_width) { 129 }
    let(:display_height) { 20 }

    specify do
      stdout = simulate_input
      expect(stdout).to(include('Your terminal size 129x20 is smaller than the minimum required 21x21. '\
'Please resize your terminal or use terminal_paint --basic'))
    end
  end
end
