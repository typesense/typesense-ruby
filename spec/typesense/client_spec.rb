require 'spec_helper'

describe Typesense::Client do
  include_context 'Typesense configuration'

  subject { typesense }

  describe '#collections' do
    context 'when no arguments are passed' do
      it 'creates a collections object and returns it' do
        result = typesense.collections

        expect(result).to be_a_kind_of(Typesense::Collections)
        expect(result.instance_variable_get(:@name)).to be_nil
      end
    end

    context 'when a collection name is passed' do
      it 'creates a collections object and returns it' do
        result = typesense.collections('companies')

        expect(result).to be_a_kind_of(Typesense::Collections)
        expect(result.instance_variable_get(:@name)).to eq('companies')
      end
    end
  end

  describe '#debug' do
    it 'creates a debug object and returns it' do
      result = typesense.debug

      expect(result).to be_a_kind_of(Typesense::Debug)
    end
  end
end
