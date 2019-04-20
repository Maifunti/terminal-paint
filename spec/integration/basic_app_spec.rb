# frozen_string_literal: true

require 'spec_helper'

describe 'Non interactive app' do
  before(:all) { require PROJECT_ROOT + '/terminal_paint/display/basic_display_adapter.rb' }

  # @return std_out and std_err outputs from running command string
  def simulate_input(string)
    old_out_pos = out_io.pos
    old_err_pos = err_io.pos
    old_input_pos = input_io.pos

    input_io << string
    input_io.pos = old_input_pos

    subject.call

    out_io.pos = old_out_pos
    err_io.pos = old_err_pos

    # remove non-visible null characters that may have been inserted by TTY::Reader while rendering the prompt
    output_string = out_io.read.delete("\u0000")
    [output_string, err_io.read]
  end

  let(:display) do
    display = TerminalPaint::Display::BasicDisplayAdapter.new(input_io, out_io, err_io)
    allow(display).to(receive(:refresh) { out_io.truncate(0) })
    display
  end

  let(:input_io) { StringIO.new }
  let(:out_io) { StringIO.new }
  let(:err_io) { StringIO.new }

  subject { -> { TerminalPaint::BasicApp.run(display) } }

  context 'invalid input' do
    specify do
      stdout, stderr = simulate_input($/)
      expect(stdout).to(eq('> '))
      expect(stderr).to(include(TerminalPaint::APP_USAGE))

      stdout, stderr = *simulate_input("Malformed Command\n")
      expect(stdout).to(eq('> '))
      expect(stderr).to(include("MALFORMED Command"))
      expect(stderr).to(include(TerminalPaint::APP_USAGE))

      stdout, stderr = *simulate_input("C 0 0 \n")
      expect(stdout).to(eq('> '))
      expect(stderr).to(include('\'C 0 0\' Size must be > 0'))
      expect(stderr).to(include(TerminalPaint::APP_USAGE))
    end
  end

  context do
    after { expect(err_io.string).to(be_empty) }

    Dir.glob(RSPEC_ROOT + "/fixtures/repl_app/*") do |test_fixture|
      it "#{File.basename(test_fixture)} fixture" do
        command_text = File.open(RSPEC_ROOT + '/fixtures/integration/' + File.basename(test_fixture) + '/command.txt').read
        expectation_text = File.open(test_fixture + '/expectation.txt').read
        stdout, stderr = *simulate_input(command_text)
        expect(stdout).to(eql(expectation_text))
        expect(stderr).to(be_empty)
      end
    end
  end
end
