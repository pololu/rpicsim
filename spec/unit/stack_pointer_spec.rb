require_relative '../spec_helper'
require 'ostruct'

describe RPicSim::StackPointer do
  let(:stkptr) { OpenStruct.new(value: stkptr_initial_value) }
  let!(:stack_pointer) { described_class.new(stkptr) }
  
  context 'on a device where stkptr starts at 0' do
    let(:stkptr_initial_value) { 0 }

    describe '#value' do
      it 'just forwards to stkptr' do
        stkptr.value = 44
        expect(stack_pointer.value).to eq 44
      end
    end
    
    describe '#value=' do
      it 'just forwards to stkptr' do
        stack_pointer.value = 5
        expect(stkptr.value).to eq 5
      end
    end
    
  end
  
  context 'on a device where stkptr starts at 31' do
    # For example, the PIC16F1826.
    let(:stkptr_initial_value) { 31 }
    
    describe '#value' do
      context 'when stkptr still has its initial value' do
        it 'returns 0' do
          expect(stack_pointer.value).to eq 0        
        end
      end
      
      context 'when stkptr is 0' do
        before do
          stkptr.value = 0
        end
      
        it 'returns 1' do
          expect(stack_pointer.value).to eq 1
        end
      end

      context 'when stkptr is one less than the initial value' do
        # NOTE: It might be impossible for stkptr to have this value.
        before do
          stkptr.value = stkptr_initial_value - 1
        end
        
        it 'returns the initial value' do
          expect(stack_pointer.value).to eq stkptr_initial_value
        end      
      end
    end
    
    describe '#value=' do
      it 'converts 0 into the initial value' do
        stack_pointer.value = 0
        expect(stkptr.value).to eq stkptr_initial_value
      end

      it 'converts 1 into 0' do
        stack_pointer.value = 1
        expect(stkptr.value).to eq 0
      end

      it 'converts the initial value into one less than the initial value' do
        # Note: This will probably not be valid on most devices; the size of the
        # stack is usually half of one plus the initial value.
        stack_pointer.value = stkptr_initial_value
        expect(stkptr.value).to eq stkptr_initial_value - 1
      end
    end
    
  end  

end
