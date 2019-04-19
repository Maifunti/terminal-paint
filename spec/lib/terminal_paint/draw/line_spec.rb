# frozen_string_literal: true

require 'spec_helper'

describe TerminalPaint::Draw::Line do
  include Test::Helper

  describe '#print' do
    let(:width) { 4 }
    let(:height) { 4 }
    let(:canvas) { TerminalPaint::Canvas.new(width, height) }

    context 'invalid parameters' do
      let(:x1) { 0 }
      let(:x2) { 0 }
      let(:y1) { 0 }
      let(:y2) { 0 }
      let(:char) { 'X' }

      subject do
        TerminalPaint::Draw::Line.print(canvas, x1, y1, x2, y2, char: char)
        print_canvas canvas
      end

      context 'null canvas parameter' do
        let(:canvas) { nil }
        it 'should raise argument error' do
          expect { subject }.to(raise_error(ArgumentError, 'Canvas must be non null'))
        end
      end

      context 'null char parameter' do
        let(:char) { nil }
        it 'asserts valid char' do
          expect(TerminalPaint::Draw::Line).to(receive(:assert_is_char).with(nil).and_call_original)
          expect { subject }.to(raise_error(ArgumentError, 'invalid char'))
        end
      end

      context 'invalid char parameter' do
        let(:char) { 1 }
        it 'asserts valid char' do
          expect(TerminalPaint::Draw::Line).to(receive(:assert_is_char).with(char).and_call_original)
          expect { subject }.to(raise_error(ArgumentError, 'invalid char'))
        end
      end

      context 'non integer coordinate parameter' do
        let(:x1) { 1.0 }
        let(:x2) { 2.0 }
        let(:y1) { 3.0 }
        let(:y2) { 3.0 }
        specify do
          expect(TerminalPaint::Draw::Line).to(receive(:assert_integer).with(x1, y1, x2, y2).and_call_original)
          expect { subject }.to(raise_error(ArgumentError, 'Coordinate must be an integer'))
        end
      end

      context 'non positive coordinate parameter' do
        let(:x1) { -1 }
        let(:x2) { -2 }
        let(:y1) { -3 }
        let(:y2) { -3 }
        specify do
          expect(TerminalPaint::Draw::Line).to(receive(:assert_positive).with(x1, y1, x2, y2).and_call_original)
          expect { subject }.to(raise_error(ArgumentError, 'Integer must be positive'))
        end
      end

      context 'coordinates specify non straight line' do
        let(:x1) { 1 }
        let(:x2) { 2 }
        let(:y1) { 3 }
        let(:y2) { 4 }

        specify do
          expect { subject }.to(raise_error(ArgumentError, 'Only Straight lines are supported'))
        end
      end
    end

    context do
      subject { print_canvas canvas }

      context 'coordinates specify a point default paint' do
        let(:expectation) do
          ['    ',
           ' x  ',
           '    ',
           '    '].join($/)
        end

        specify do
          TerminalPaint::Draw::Line.print(canvas, 1, 1, 1, 1)
          expect(subject).to(eql(expectation))
        end
      end

      context 'coordinates specify a point with specified paint' do
        let(:expectation) do
          ['    ',
           ' *  ',
           '    ',
           '    '].join($/)
        end

        specify do
          TerminalPaint::Draw::Line.print(canvas, 1, 1, 1, 1, char: '*')
          expect(subject).to(eql(expectation))
        end
      end

      context 'coordinates specify horizontal line within canvas' do
        let(:expectation) do
          ['    ',
           ' xxx',
           '    ',
           '    '].join($/)
        end

        specify do
          TerminalPaint::Draw::Line.print(canvas, 1, 1, 3, 1)
          expect(subject).to(eql(expectation))
        end
      end

      context 'coordinates specify reversed horizontal line within canvas' do
        let(:expectation) do
          ['    ',
           ' xxx',
           '    ',
           '    '].join($/)
        end

        specify do
          TerminalPaint::Draw::Line.print(canvas, 3, 1, 1, 1)
          expect(subject).to(eql(expectation))
        end
      end

      context 'coordinates specify horizontal line ending outside canvas' do
        let(:expectation) do
          ['    ',
           ' xxx',
           '    ',
           '    '].join($/)
        end

        specify do
          TerminalPaint::Draw::Line.print(canvas, 1, 1, 50, 1)
          expect(subject).to(eql(expectation))
        end
      end

      context 'coordinates specify vertical line within canvas' do
        let(:expectation) do
          ['    ',
           ' x  ',
           ' x  ',
           ' x  '].join($/)
        end

        specify do
          TerminalPaint::Draw::Line.print(canvas, 1, 1, 1, 3)
          expect(subject).to(eql(expectation))
        end
      end

      context 'coordinates specify reversed vertical line within canvas' do
        let(:expectation) do
          ['    ',
           ' x  ',
           ' x  ',
           ' x  '].join($/)
        end

        specify do
          TerminalPaint::Draw::Line.print(canvas, 1, 3, 1, 1)
          expect(subject).to(eql(expectation))
        end
      end

      context 'coordinates specify vertical line ending outside canvas' do
        let(:expectation) do
          ['    ',
           ' x  ',
           ' x  ',
           ' x  '].join($/)
        end

        specify do
          TerminalPaint::Draw::Line.print(canvas, 1, 1, 1, 50)
          expect(subject).to(eql(expectation))
        end
      end

      context 'multiple invocations can overlap' do
        let(:expectation) do
          ['*xx&',
           '*  &',
           '*  &',
           '===&'].join($/)
        end

        specify do
          TerminalPaint::Draw::Line.print(canvas, 0, 0, 3, 0)
          TerminalPaint::Draw::Line.print(canvas, 0, 0, 0, 3, char: '*')
          TerminalPaint::Draw::Line.print(canvas, 0, 3, 3, 3, char: '=')
          TerminalPaint::Draw::Line.print(canvas, 3, 0, 3, 3, char: '&')
          expect(subject).to(eql(expectation))
        end
      end

      context 'can print on minimum canvas size' do
        let(:width) { 1 }
        let(:height) { 1 }
        let(:expectation) { 'x' }

        specify do
          TerminalPaint::Draw::Line.print(canvas, 0, 0, 0, 0)
          expect(subject).to(eql(expectation))
        end
      end

      context 'can print on non-square canvas size' do
        let(:width) { 10 }
        let(:height) { 4 }
        let(:expectation) do
          ['          ',
           'xxxxxxxxxx',
           '    x     ',
           '    x     '].join($/)
        end

        specify do
          TerminalPaint::Draw::Line.print(canvas, 0, 1, 9, 1)
          TerminalPaint::Draw::Line.print(canvas, 4, 1, 4, 3)
          expect(subject).to(eql(expectation))
        end
      end
    end
  end
end
