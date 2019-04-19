# frozen_string_literal: true

require 'spec_helper'
require 'support/test_tty_display'

describe 'Interactive app using TTYDisplayAdapter' do
  # @return std_out and std_err outputs from running command string
  def simulate_input(string)
    old_input_pos = input_io.pos
    input_io << string
    input_io.pos = old_input_pos

    subject.call

    test_display.get_captured_output
  end

  let(:display_width) { 100 }
  let(:display_height) { 100 }
  let(:input_io) { StringIO.new }
  let(:out_io) { StringIO.new }
  let(:err_io) { StringIO.new }
  let(:test_display) { Test::TTYDisplayAdapter.build(display_width, display_height, input_io, out_io) }
  let(:test_app) { TerminalPaint::InteractiveApp.new(test_display) }

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
    let(:display_width) { 130 }
    let(:display_height) { 20 }

    specify do
      stdout, _stderr = simulate_input('C 100 100')
      expect(stdout).to(include('Your terminal size 130x20 is smaller than the minimum required 21x21. '\
'Please resize your terminal or use terminal_paint --basic'))
    end
  end
end
