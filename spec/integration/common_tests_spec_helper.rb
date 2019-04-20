# frozen_string_literal: true

shared_examples 'it can scroll' do
  it "can scroll" do
    command_text = File.open(RSPEC_ROOT + '/fixtures/scrolling/command.txt').read
    simulate_input command_text

    base_expectation = File.open(RSPEC_ROOT + '/fixtures/scrolling/base_expectation.txt').read

    test_app.scroll(150, 150)
    test_app.run # refresh display
    expect(test_display.get_captured_output).to(eq(base_expectation))

    test_app.scroll(20, 0)
    test_app.run
    scroll_horizontal_1 = File.open(RSPEC_ROOT + '/fixtures/scrolling/scroll_horizontal_expectation.txt').read
    expect(test_display.get_captured_output).to(eq(scroll_horizontal_1))

    test_app.scroll(-20, 0)
    test_app.run
    expect(test_display.get_captured_output).to(eq(base_expectation))

    test_app.scroll(0, 20)
    test_app.run
    scroll_vertical_1 = File.open(RSPEC_ROOT + '/fixtures/scrolling/scroll_vertical_expectation.txt').read
    expect(test_display.get_captured_output).to(eq(scroll_vertical_1))

    test_app.scroll(0, -20)
    test_app.run
    expect(test_display.get_captured_output).to(eq(base_expectation))
  end
end

shared_examples 'shows small screen error' do
  let(:display_width) { 130 }
  let(:display_height) { 20 }

  it 'shows small screen error' do
    stdout, _stderr = simulate_input('C 100 100')
    expect(stdout).to(include('Your terminal size 130x20 is smaller than the minimum required 22x22. '\
'Please resize your terminal or use terminal_paint --basic'))
  end
end

