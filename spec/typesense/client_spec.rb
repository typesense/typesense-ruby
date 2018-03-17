# frozen_string_literal: true

require 'spec_helper'

describe Typesense::Client do
  include_context 'Typesense configuration'

  subject(:typesence) { typesense }

  describe '#collections' do
    it 'creates a collections object and returns it' do
      result = typesense.collections

      expect(result).to be_a_kind_of(Typesense::Collections)
    end
  end

  describe '#debug' do
    it 'creates a debug object and returns it' do
      result = typesense.debug

      expect(result).to be_a_kind_of(Typesense::Debug)
    end
  end
end
