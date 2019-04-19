# frozen_string_literal: true

require 'spec_helper'

describe TerminalPaint::Draw::SolidRectangle do
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
        TerminalPaint::Draw::SolidRectangle.print(canvas, x1, y1, x2, y2, char: char)
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
          expect(TerminalPaint::Draw::SolidRectangle).to(receive(:assert_is_char).with(nil).and_call_original)
          expect { subject }.to(raise_error(ArgumentError, 'invalid char'))
        end
      end

      context 'non integer coordinate parameter' do
        let(:x1) { 1.0 }
        let(:x2) { 2.0 }
        let(:y1) { 3.0 }
        let(:y2) { 3.0 }
        specify do
          expect(TerminalPaint::Draw::SolidRectangle).to(receive(:assert_integer).with(x1, y1, x2, y2).and_call_original)
          expect { subject }.to(raise_error(ArgumentError, 'Coordinate must be an integer'))
        end
      end

      context 'non positive coordinate parameter' do
        let(:x1) { -1 }
        let(:x2) { -2 }
        let(:y1) { -3 }
        let(:y2) { -3 }
        specify do
          expect(TerminalPaint::Draw::SolidRectangle).to(receive(:assert_positive).with(x1, y1, x2, y2).and_call_original)
          expect { subject }.to(raise_error(ArgumentError, 'Integer must be positive'))
        end
      end
    end

    context do
      subject { print_canvas canvas }

      context 'coordinates specify a point' do
        let(:expectation) do
          ['    ',
           ' x  ',
           '    ',
           '    '].join($/)
        end

        specify do
          TerminalPaint::Draw::SolidRectangle.print(canvas, 1, 1, 1, 1)
          expect(subject).to(eql(expectation))
        end
      end

      context 'coordinates specify a point' do
        let(:expectation) do
          ['    ',
           ' *  ',
           '    ',
           '    '].join($/)
        end

        specify do
          TerminalPaint::Draw::SolidRectangle.print(canvas, 1, 1, 1, 1, char: '*')
          expect(subject).to(eql(expectation))
        end
      end

      context 'coordinates specify horizontal line' do
        let(:expectation) do
          ['    ',
           ' xxx',
           '    ',
           '    '].join($/)
        end

        specify do
          TerminalPaint::Draw::SolidRectangle.print(canvas, 1, 1, 3, 1)
          expect(subject).to(eql(expectation))
        end
      end

      context 'coordinates specify vertical line' do
        let(:expectation) do
          ['    ',
           ' x  ',
           ' x  ',
           '    '].join($/)
        end

        specify do
          TerminalPaint::Draw::SolidRectangle.print(canvas, 1, 1, 1, 2)
          expect(subject).to(eql(expectation))
        end
      end

      context 'coordinates specify rectangle inside canvas' do
        let(:expectation) do
          ['    ',
           ' xx ',
           ' xx ',
           ' xx '].join($/)
        end

        specify do
          TerminalPaint::Draw::SolidRectangle.print(canvas, 1, 1, 2, 3)
          expect(subject).to(eql(expectation))
        end
      end

      context 'coordinates specify rectangle inside canvas' do
        let(:expectation) do
          [' xx ',
           ' xx ',
           ' xx ',
           '    '].join($/)
        end

        specify do
          TerminalPaint::Draw::SolidRectangle.print(canvas, 1, 0, 2, 2)
          expect(subject).to(eql(expectation))
        end
      end

      context 'coordinates specify rectangle partly drawn outside canvas' do
        let(:expectation) do
          ['xxxx',
           'xxxx',
           'xxxx',
           'xxxx'].join($/)
        end

        specify do
          TerminalPaint::Draw::SolidRectangle.print(canvas, 0, 0, 50, 50)
          expect(subject).to(eql(expectation))
        end
      end

      context 'can print on minimum canvas size' do
        let(:width) { 1 }
        let(:height) { 1 }
        let(:expectation) { 'x' }

        specify do
          TerminalPaint::Draw::SolidRectangle.print(canvas, 0, 0, 0, 0)
          expect(subject).to(eql(expectation))
        end
      end

      context 'can print on non-square canvas size' do
        let(:width) { 10 }
        let(:height) { 4 }
        let(:expectation) do
          ['xxxxxxxxxx',
           'xxxxxxxxxx',
           'xxxxxxxxxx',
           'xxxxxxxxxx'].join($/)
        end

        specify do
          TerminalPaint::Draw::SolidRectangle.print(canvas, 0, 0, 9, 3)
          expect(subject).to(eql(expectation))
        end
      end

      context 'multiple invocations can overlap' do
        let(:expectation) do
          ['xxxx',
           'xyyy',
           'xyzz',
           'xyzz'].join($/)
        end

        specify do
          TerminalPaint::Draw::SolidRectangle.print(canvas, 0, 0, 10, 10)
          TerminalPaint::Draw::SolidRectangle.print(canvas, 1, 1, 10, 10, char: 'y')
          TerminalPaint::Draw::SolidRectangle.print(canvas, 2, 2, 10, 10, char: 'z')
          expect(subject).to(eql(expectation))
        end
      end

      context 'multiple invocations can overlap' do
        let(:width) { 10 }
        let(:height) { 5 }
        let(:expectation) do
          ['1111111111',
           '1222222221',
           '1233333321',
           '1222222221',
           '1111111111'].join($/)
        end

        specify do
          TerminalPaint::Draw::SolidRectangle.print(canvas, 0, 0, 9, 4, char: '1')
          TerminalPaint::Draw::SolidRectangle.print(canvas, 1, 1, 8, 3, char: '2')
          TerminalPaint::Draw::SolidRectangle.print(canvas, 2, 2, 7, 2, char: '3')
          expect(subject).to(eql(expectation))
        end
      end
    end
  end
end
