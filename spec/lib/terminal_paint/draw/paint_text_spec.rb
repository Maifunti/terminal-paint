# frozen_string_literal: true

require 'spec_helper'

describe TerminalPaint::Draw::PaintText do
  include Test::Helper

  describe '#print' do
    let(:width) { 4 }
    let(:height) { 4 }
    let(:canvas) { TerminalPaint::Canvas.new(width, height) }

    context 'invalid parameters' do
      let(:x) { 0 }
      let(:y) { 0 }
      let(:text) { 'foo-bar-da-hoo-tar' }

      subject do
        TerminalPaint::Draw::PaintText.print(canvas, x, y, text)
        print_canvas canvas
      end

      context 'null canvas parameter' do
        let(:canvas) { nil }
        it 'should raise argument error' do
          expect { subject }.to(raise_error(ArgumentError, 'Canvas must be non null'))
        end
      end

      context 'non integer coordinate parameter' do
        let(:x) { 1.0 }
        let(:y) { 3.0 }
        specify do
          expect(TerminalPaint::Draw::PaintText).to(receive(:assert_integer).with(x, y).and_call_original)
          expect { subject }.to(raise_error(ArgumentError, 'Coordinate must be an integer'))
        end
      end

      context 'non positive coordinate parameter' do
        let(:x) { -1 }
        let(:y) { -3 }
        specify do
          expect(TerminalPaint::Draw::PaintText).to(receive(:assert_positive).with(x, y).and_call_original)
          expect { subject }.to(raise_error(ArgumentError, 'Integer must be positive'))
        end
      end
    end

    context do
      subject { print_canvas canvas }

      context 'null text parameter' do
        let(:expectation) do
          ['    ',
           '    ',
           '    ',
           '    '].join($INPUT_RECORD_SEPARATOR)
        end
        let(:text) { nil }

        specify do
          TerminalPaint::Draw::PaintText.print(canvas, 1, 1, nil)
          expect(subject).to(eql(expectation))
        end
      end

      context 'empty text parameter' do
        let(:expectation) do
          ['    ',
           '    ',
           '    ',
           '    '].join($INPUT_RECORD_SEPARATOR)
        end
        let(:text) { nil }

        specify do
          TerminalPaint::Draw::PaintText.print(canvas, 1, 1, '')
          expect(subject).to(eql(expectation))
        end
      end

      context 'single line of text fitting within canvas' do
        let(:width) { 11 }
        let(:expectation) do
          ['Hello Paint',
           '           ',
           '           ',
           '           '].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          TerminalPaint::Draw::PaintText.print(canvas, 0, 0, 'Hello Paint')
          expect(subject).to(eql(expectation))
        end
      end

      context 'single line of text overflowing canvas' do
        let(:width) { 9 }
        let(:expectation) do
          ['Hello Pai',
           '         ',
           '         ',
           '         '].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          TerminalPaint::Draw::PaintText.print(canvas, 0, 0, 'Hello Paint')
          expect(subject).to(eql(expectation))
        end
      end

      context 'single line of text outside canvas' do
        let(:width) { 9 }
        let(:expectation) do
          ['         ',
           '         ',
           '         ',
           '         '].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          TerminalPaint::Draw::PaintText.print(canvas, 0, 10, 'Hello Paint')
          expect(subject).to(eql(expectation))
        end
      end

      context 'Multi-line of text within canvas dimensions' do
        let(:width) { 10 }
        let(:expectation) do
          ['          ',
           ' Terminal ',
           '   Paint  ',
           '          '].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          text = "          \n Terminal \n   Paint  \n          "
          TerminalPaint::Draw::PaintText.print(canvas, 0, 0, text)
          expect(subject).to(eql(expectation))
        end
      end

      context 'Multi-line of text overflowing canvas dimensions' do
        let(:width) { 10 }
        let(:expectation) do
          ['          ',
           ' Terminal ',
           '   Paint  ',
           '          '].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          text = "          \n Terminal \n   Paint  \n          \n Rocks!"
          TerminalPaint::Draw::PaintText.print(canvas, 0, 0, text)
          expect(subject).to(eql(expectation))
        end
      end

      context 'multiple invocations can overlap' do
        let(:width) { 10 }
        let(:expectation) do
          ['Happy     ',
           ' Terminal ',
           '   Paint  ',
           '    Skills'].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          text1 = "          \n Terminal \n   Paint  \n          \n Rocks!"
          TerminalPaint::Draw::PaintText.print(canvas, 0, 0, text1)
          TerminalPaint::Draw::PaintText.print(canvas, 0, 0, 'Happy')
          TerminalPaint::Draw::PaintText.print(canvas, 1, 3, '   Skills')
          expect(subject).to(eql(expectation))
        end
      end

      context 'can print on minimum canvas size' do
        let(:width) { 1 }
        let(:height) { 1 }
        let(:expectation) { 'x' }

        specify do
          TerminalPaint::Draw::PaintText.print(canvas, 0, 0, 'xxx')
          expect(subject).to(eql(expectation))
        end
      end
    end
  end
end
