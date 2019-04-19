# frozen_string_literal: true

require 'spec_helper'

context 'invocation ' do
  before { stub_const 'ARGV', arguments }

  subject { load File.join(PROJECT_ROOT, '../bin/terminal-paint') }

  context 'bad arguments' do
    let(:arguments) { %w(--illegal-argument) }

    it 'shows command line usage prompt' do
      expect { subject }.to(output(TerminalPaint::COMMAND_LINE_USAGE).to_stdout)
    end
  end

  context '--basic' do
    let(:arguments) { %w(--basic) }

    it 'launches basic App' do
      expect(TerminalPaint::BasicApp).to(receive(:run))

      expect { subject }.to_not(output.to_stdout)
    end
  end

  context '--tty-cursor' do
    let(:arguments) { %w(--tty-cursor) }
    before { require File.join(PROJECT_ROOT, '/terminal_paint/display/tty_display_adapter.rb') }

    it 'launches Interactive App with tty_cursor display adapter' do
      display_instance_stub = instance_double(TerminalPaint::Display::TTYDisplayAdapter)
      class_double(TerminalPaint::Display::TTYDisplayAdapter, new: display_instance_stub).as_stubbed_const

      expect(TerminalPaint::InteractiveApp).to(receive(:run).with(display_instance_stub))

      expect { subject }.to_not(output.to_stdout)
    end
  end

  context '--ncurses', :requires_curses do
    let(:arguments) { %w(--ncurses) }

    before { require File.join(PROJECT_ROOT, '/terminal_paint/display/curses_display_adapter.rb') }

    it 'launches Interactive App with tty_cursor display adapter' do
      display_instance_stub = instance_double(TerminalPaint::Display::CursesDisplayAdapter)
      class_double(TerminalPaint::Display::CursesDisplayAdapter, new: display_instance_stub).as_stubbed_const

      expect(TerminalPaint::InteractiveApp).to(receive(:run).with(display_instance_stub))

      expect { subject }.to_not(output.to_stdout)
    end
  end
end
