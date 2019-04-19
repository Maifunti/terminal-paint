# frozen_string_literal: true

require 'spec_helper'

describe TerminalPaint::Draw::FloodFill do
  include Test::Helper

  describe '#print' do
    let(:width) { 6 }
    let(:height) { 6 }
    let(:canvas) { TerminalPaint::Canvas.new(width, height) }

    context 'invalid parameters' do
      let(:x) { 0 }
      let(:y) { 0 }
      let(:replacement_color) { 'X' }

      subject do
        TerminalPaint::Draw::FloodFill.print(canvas, x, y, replacement_color)
        print_canvas canvas
      end

      context 'null canvas parameter' do
        let(:canvas) { nil }
        it 'should raise argument error' do
          expect { subject }.to(raise_error(ArgumentError, 'Canvas must be non null'))
        end
      end

      context 'invalid char parameter' do
        let(:replacement_color) { 1 }
        it 'asserts valid char' do
          expect(TerminalPaint::Draw::FloodFill).to(receive(:assert_is_char).with(replacement_color).and_call_original)
          expect { subject }.to(raise_error(ArgumentError, 'invalid char'))
        end
      end

      context 'non integer coordinate parameter' do
        let(:x) { 1.0 }
        let(:y) { 3.0 }
        specify do
          expect(TerminalPaint::Draw::FloodFill).to(receive(:assert_integer).with(x, y).and_call_original)
          expect { subject }.to(raise_error(ArgumentError, 'Coordinate must be an integer'))
        end
      end

      context 'non positive coordinate parameter' do
        let(:x) { -1 }
        let(:y) { -3 }
        specify do
          expect(TerminalPaint::Draw::FloodFill).to(receive(:assert_positive).with(x, y).and_call_original)
          expect { subject }.to(raise_error(ArgumentError, 'Integer must be positive'))
        end
      end
    end

    context do
      before do
        pre_state.lines.each_with_index do |line, row_index|
          line.each_char.with_index do |char, col_index|
            canvas.set_value(col_index, row_index, char)
          end
        end
      end

      subject { print_canvas canvas }

      context 'target is completely surrounded by candidates' do
        let(:pre_state) do
          ['      ',
           '      ',
           '      ',
           '      ',
           '      ',
           '      '].join($INPUT_RECORD_SEPARATOR)
        end

        let(:post_state) do
          ['******',
           '******',
           '******',
           '******',
           '******',
           '******'].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 1, 1, '*')
          expect(subject).to(eql(post_state))
        end
      end

      context 'target has no surrounding candidates' do
        let(:pre_state) do
          [' XXXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX'].join($INPUT_RECORD_SEPARATOR)
        end

        let(:post_state) do
          ['*XXXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX'].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 0, 0, '*')
          expect(subject).to(eql(post_state))
        end
      end

      context 'target has no surrounding candidates' do
        let(:pre_state) do
          ['X XXXX',
           '  XXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX'].join($INPUT_RECORD_SEPARATOR)
        end

        let(:post_state) do
          ['* XXXX',
           '  XXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX'].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 0, 0, '*')
          expect(subject).to(eql(post_state))
        end
      end

      context 'target has surrounding candidates only on same row' do
        let(:pre_state) do
          ['XX XXX',
           '  XXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX'].join($INPUT_RECORD_SEPARATOR)
        end

        let(:post_state) do
          ['** XXX',
           '  XXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX'].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 0, 0, '*')
          expect(subject).to(eql(post_state))
        end
      end

      context 'target has surrounding candidates only on same row' do
        let(:pre_state) do
          ['XXXXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXX  ',
           'XXX XX'].join($INPUT_RECORD_SEPARATOR)
        end

        let(:post_state) do
          ['XXXXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXX  ',
           'XXX **'].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 5, 5, '*')
          expect(subject).to(eql(post_state))
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 4, 5, '*')
          expect(subject).to(eql(post_state))
        end
      end

      context 'target has surrounding candidates on multiple rows' do
        let(:pre_state) do
          ['XX XXX',
           'XX XXX',
           '  XXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX'].join($INPUT_RECORD_SEPARATOR)
        end

        let(:post_state) do
          ['** XXX',
           '** XXX',
           '  XXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXXXX'].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 0, 0, '*')
          expect(subject).to(eql(post_state))
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 1, 1, '*')
          expect(subject).to(eql(post_state))
        end
      end

      context 'target has surrounding candidates on multiple rows' do
        let(:pre_state) do
          ['XXXXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXX  ',
           'XXX XX',
           'XXX XX'].join($INPUT_RECORD_SEPARATOR)
        end

        let(:post_state) do
          ['XXXXXX',
           'XXXXXX',
           'XXXXXX',
           'XXXX  ',
           'XXX **',
           'XXX **'].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 5, 5, '*')
          expect(subject).to(eql(post_state))
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 4, 4, '*')
          expect(subject).to(eql(post_state))
        end
      end

      context 'target has surrounding candidates on multiple rows' do
        let(:pre_state) do
          ['   X  ',
           '   X  ',
           '   X  ',
           '   X  ',
           '   X  ',
           '   X  '].join($INPUT_RECORD_SEPARATOR)
        end

        let(:post_state) do
          ['   *  ',
           '   *  ',
           '   *  ',
           '   *  ',
           '   *  ',
           '   *  '].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 3, 0, '*')
          expect(subject).to(eql(post_state))
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 3, 5, '*')
          expect(subject).to(eql(post_state))
        end
      end

      context 'target has surrounding candidates on multiple rows' do
        let(:pre_state) do
          ['  *X* ',
           '  *X* ',
           '  *X* ',
           '  *X* ',
           '  *X* ',
           '  *X* '].join($INPUT_RECORD_SEPARATOR)
        end

        let(:post_state) do
          ['  *** ',
           '  *** ',
           '  *** ',
           '  *** ',
           '  *** ',
           '  *** '].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 3, 0, '*')
          expect(subject).to(eql(post_state))
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 3, 5, '*')
          expect(subject).to(eql(post_state))
        end
      end

      context 'target has surrounding candidates on multiple rows' do
        let(:pre_state) do
          ['  -X- ',
           '  -X- ',
           '  -X- ',
           '  -X- ',
           '  -X- ',
           '  -X- '].join($INPUT_RECORD_SEPARATOR)
        end

        let(:post_state) do
          ['  -*- ',
           '  -*- ',
           '  -*- ',
           '  -*- ',
           '  -*- ',
           '  -*- '].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 3, 0, '*')
          expect(subject).to(eql(post_state))
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 3, 5, '*')
          expect(subject).to(eql(post_state))
        end
      end

      context 'target has surrounding candidates on multiple rows' do
        let(:pre_state) do
          ['  -X- ',
           '---X--',
           'XXXXXX',
           '---X--',
           ' --X- ',
           ' --X- '].join($INPUT_RECORD_SEPARATOR)
        end

        let(:post_state) do
          ['  -*- ',
           '---*--',
           '******',
           '---*--',
           ' --*- ',
           ' --*- '].join($INPUT_RECORD_SEPARATOR)
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 3, 0, '*')
          expect(subject).to(eql(post_state))
        end

        specify do
          TerminalPaint::Draw::FloodFill.print(canvas, 3, 5, '*')
          expect(subject).to(eql(post_state))
        end
      end
    end
  end
end
