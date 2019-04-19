# frozen_string_literal: true

require 'spec_helper'

describe TerminalPaint::Draw::Border do
  include Test::Helper

  describe '#print' do
    let(:width) { 4 }
    let(:height) { 4 }
    let(:canvas) { TerminalPaint::Canvas.new width, height }

    context 'invalid parameters' do
      let(:x1) { 0 }
      let(:x2) { 0 }
      let(:y1) { 0 }
      let(:y2) { 0 }
      let(:style) { 'X' }

      subject do
        TerminalPaint::Draw::Border.print canvas, x1, y1, x2, y2, style: style
        print_canvas canvas
      end

      context 'null canvas parameter' do
        let(:canvas) { nil }
        it 'should raise argument error' do
          expect { subject }.to raise_error ArgumentError, 'Canvas must be non null'
        end
      end

      context 'null style parameter' do
        let(:style) { nil }
        it 'asserts valid char' do
          expect { subject }.to raise_error ArgumentError, 'style must be non null'
        end
      end

      context 'invalid style parameter' do
        let(:style) { :foo }
        it 'asserts valid char' do
          expect { subject }.to raise_error ArgumentError, 'Invalid Style'
        end
      end

      context 'non integer coordinate parameter' do
        let(:x1) { 1.0 }
        let(:x2) { 2.0 }
        let(:y1) { 3.0 }
        let(:y2) { 3.0 }
        specify do
          expect(TerminalPaint::Draw::Border).to receive(:assert_integer).with(x1, y1, x2, y2).and_call_original
          expect { subject }.to raise_error ArgumentError, 'Coordinate must be an integer'
        end
      end

      context 'non positive coordinate parameter' do
        let(:x1) { -1 }
        let(:x2) { -2 }
        let(:y1) { -3 }
        let(:y2) { -3 }
        specify do
          expect(TerminalPaint::Draw::Border).to receive(:assert_positive).with(x1, y1, x2, y2).and_call_original
          expect { subject }.to raise_error ArgumentError, 'Integer must be positive'
        end
      end
    end

    context do
      subject { print_canvas canvas }

      context 'coordinates specify a point' do
        let(:expectation) do
          ['    ',
           ' +  ',
           '    ',
           '    '].join $/
        end

        specify do
          TerminalPaint::Draw::Border.print canvas, 1, 1, 1, 1
          expect(subject).to eql expectation
        end
      end

      context 'coordinates specify a point' do
        let(:expectation) do
          ['    ',
           ' ╝  ',
           '    ',
           '    '].join $/
        end

        specify do
          TerminalPaint::Draw::Border.print canvas, 1, 1, 1, 1, style: :thick
          expect(subject).to eql expectation
        end
      end

      context 'coordinates specify horizontal line' do
        let(:expectation) do
          ['+--+',
           '    ',
           '    ',
           '    '].join $/
        end

        specify do
          TerminalPaint::Draw::Border.print canvas, 0, 0, 3, 0
          expect(subject).to eql expectation
        end
      end

      context 'coordinates specify vertical line' do
        let(:expectation) do
          [' +  ',
           ' |  ',
           ' |  ',
           ' +  '].join $/
        end

        specify do
          TerminalPaint::Draw::Border.print canvas, 1, 0, 1, 3
          expect(subject).to eql expectation
        end
      end

      context 'coordinates specify a 2 row border' do
        let(:expectation) do
          ['+--+',
           '+--+',
           '    ',
           '    '].join $/
        end

        specify do
          TerminalPaint::Draw::Border.print canvas, 0, 0, 3, 1
          expect(subject).to eql expectation
        end
      end

      context 'coordinates specify a 3 row border' do
        let(:expectation) do
          ['    ',
           '+--+',
           '|  |',
           '+--+'].join $/
        end

        specify do
          TerminalPaint::Draw::Border.print canvas, 0, 1, 3, 3
          expect(subject).to eql expectation
        end
      end

      context 'coordinates specify a multi row border' do
        let(:width) { 10 }
        let(:height) { 5 }
        let(:expectation) do
          ['+--------+',
           '|        |',
           '|        |',
           '|        |',
           '+--------+'].join $/
        end

        specify do
          TerminalPaint::Draw::Border.print canvas, 0, 0, 9, 4
          expect(subject).to eql expectation
        end
      end


      context 'multiple invocations can overlap' do
        let(:width) { 10 }
        let(:height) { 6 }
        let(:expectation) do
          ['+--------+',
           '|╔══════╗|',
           '|║┌────┐║|',
           '|║└────┘║|',
           '|╚══════╝|',
           '+--------+'].join $/
        end

        specify do
          TerminalPaint::Draw::Border.print canvas, 0, 0, 9, 5
          TerminalPaint::Draw::Border.print canvas, 1, 1, 8, 4, style: :thick
          TerminalPaint::Draw::Border.print canvas, 2, 2, 7, 3, style: :light
          expect(subject).to eql expectation
        end
      end

      context 'can print on minimum canvas size' do
        let(:width) { 1 }
        let(:height) { 1 }
        let(:expectation) { '+' }

        specify do
          TerminalPaint::Draw::Border.print canvas, 0, 0, 0, 0
          expect(subject).to eql expectation
        end
      end

      context 'can print on non-square canvas size' do
        let(:width) { 10 }
        let(:height) { 4 }
        let(:expectation) do
          ['+--------+',
           '|        |',
           '|        |',
           '+--------+'].join $/
        end

        specify do
          TerminalPaint::Draw::Border.print canvas, 0, 0, 9, 3
          expect(subject).to eql expectation
        end
      end
    end
  end
end