# frozen_string_literal: true

require 'spec_helper'

describe TerminalPaint::Controller do
  let(:interface_double) do
    instance_double(TerminalPaint::ControllerInterface).tap do |interface|
      allow(interface).to receive(:new_canvas)
    end
  end
  let(:controller) { TerminalPaint::Controller.new(interface_double) }

  describe '#process_string' do
    subject { controller.process_string command }

    context 'empty command' do
      let(:command){ }
      specify do
        expect(subject.success).to be false
        expect(subject.formatted_message).to eq '\'\' Bad Input'
      end
    end

    context 'unkwnown command' do
      let(:command){ 'X' }
      specify do
        expect(subject.success).to be false
        expect(subject.formatted_message).to eq '\'X\' Unknown command'
      end
    end

    context 'C' do
      context 'bad arguments' do
        let(:command){ 'C 10' }
        specify do
          expect(subject.success).to be false
          expect(subject.formatted_message).to eq '\'C 10\' Illegal Arguments'
        end
      end

      context 'bad arguments (non-integer)' do
        let(:command){ 'C 10 F' }
        specify do
          expect(subject.success).to be false
          expect(subject.formatted_message).to eq '\'C 10 F\' Size must be an integer'
        end
      end

      context 'good arguments' do
        let(:command){ 'C 50 100' }
        specify do
          expect(interface_double).to receive(:new_canvas) do |canvas|
            expect(canvas.width).to eq 50
            expect(canvas.height).to eq 100
          end
          expect(subject.success).to be true
          expect(subject.formatted_message).to eq 'C 50 100'
        end
      end
    end

    context 'L' do
      context 'no canvas' do
        let(:command){ 'L 10' }
        specify do
          expect(subject.success).to be false
          expect(subject.formatted_message).to eq '\'L 10\' First create a new canvas'
        end
      end

      context 'canvas present' do
        before { controller.process_string('C 100 100') }

        context 'bad arguments' do
          let(:command){ 'L 10' }
          specify do
            expect(subject.success).to be false
            expect(subject.formatted_message).to eq '\'L 10\' Illegal Arguments'
          end
        end

        context 'bad arguments (non-integer)' do
          let(:command){ 'L 10 x 10 20' }
          specify do
            expect(subject.success).to be false
            expect(subject.formatted_message).to eq '\'L 10 x 10 20\' Illegal Arguments. Size must be an integer'
          end
        end

        context 'bad arguments (non-straight line)' do
          let(:command){ 'L 10 11 12 13' }
          specify do
            expect(subject.success).to be false
            expect(subject.formatted_message).to eq "'L 10 11 12 13' Illegal Arguments. Arguments "\
"'[\"10\", \"11\", \"12\", \"13\"]' do not specify a straight line"
          end
        end

        context 'good arguments' do
          let(:command){ 'L 1 50 50 50' }

          specify do
            expect(TerminalPaint::Draw::Line).to receive(:print)
              .with(controller.canvas, 0, 49, 49, 49).and_call_original
            expect(subject.formatted_message).to eq 'L 1 50 50 50'
            expect(subject.success).to be true
          end
        end
      end
    end

    context 'R' do
      context 'no canvas' do
        let(:command){ 'R 10' }
        specify do
          expect(subject.success).to be false
          expect(subject.formatted_message).to eq '\'R 10\' First create a new canvas'
        end
      end

      context 'canvas present' do
        before { controller.process_string('C 100 100') }

        context 'bad arguments' do
          let(:command){ 'R 10' }
          specify do
            expect(subject.success).to be false
            expect(subject.formatted_message).to eq '\'R 10\' Illegal Arguments'
          end
        end

        context 'bad arguments (non-integer)' do
          let(:command){ 'R 10 10 10 X' }
          specify do
            expect(subject.success).to be false
            expect(subject.formatted_message).to eq '\'R 10 10 10 X\' Illegal Arguments. Size must be an integer'
          end
        end

        context 'good arguments' do
          let(:command){ 'R 1 50 50 50' }

          specify do
            expect(TerminalPaint::Draw::Rectangle).to receive(:print)
              .with(controller.canvas, 0, 49, 49, 49).and_call_original
            expect(subject.formatted_message).to eq 'R 1 50 50 50'
            expect(subject.success).to be true
          end
        end
      end
    end

    context 'B' do
      context 'no canvas' do
        let(:command){ 'B 10' }
        specify do
          expect(subject.success).to be false
          expect(subject.formatted_message).to eq '\'B 10\' First create a new canvas'
        end
      end

      context 'canvas present' do
        before { controller.process_string('C 100 100') }

        context 'bad arguments' do
          let(:command){ 'B 10' }
          specify do
            expect(subject.success).to be false
            expect(subject.formatted_message).to eq '\'B 10\' Illegal Arguments'
          end
        end

        context 'bad arguments (non-integer)' do
          let(:command){ 'B A D U' }
          specify do
            expect(subject.success).to be false
            expect(subject.formatted_message).to eq '\'B A D U\' Illegal Arguments. Size must be an integer'
          end
        end

        context 'good arguments' do
          let(:command){ 'B 1 50 *' }

          specify do
            expect(TerminalPaint::Draw::FloodFill).to receive(:print)
              .with(controller.canvas, 0, 49, '*').and_call_original
            expect(subject.formatted_message).to eq 'B 1 50 *'
            expect(subject.success).to be true
          end
        end
      end
    end

    context 'Q' do
      let(:command) { 'Q' }

      specify do
        expect(subject.exiting?).to be true
        expect(subject.success).to be true
      end
    end
  end
end