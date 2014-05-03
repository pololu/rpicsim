require_relative '../../spec_helper'

describe RPicSim::Mplab::MplabProgramFile do
  let(:device) { 'PIC18F45K50' }
  let(:filename) { Firmware::NestedSubroutines.filename }

  describe '.new' do

    context 'when given a filename that does not exist' do
      let(:filename) { 'not_found.txt' }

      it 'raises an exception saying so' do
        error_message = 'File does not exist: not_found.txt'
        expect { described_class.new(filename, device) }.to raise_error error_message
      end
    end

    context 'when given a filename that exists but is not in a dist directory' do
      let(:filename) { 'spec/firmware/BoringLoop.cof' }

      it 'raises an exception saying so' do
        error_message = 'The file must be inside a directory named dist or else the MCLoader ' \
                        'class will throw an exception saying that it cannot find the COF file.'
        expect { described_class.new(filename, device) }.to raise_error error_message
      end
    end

  end
end
