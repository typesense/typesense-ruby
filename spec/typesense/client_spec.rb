# frozen_string_literal: true

require_relative '../spec_helper'

describe Typesense::Client do
  subject(:typesence) { typesense }

  include_context 'with Typesense configuration'

  describe '#collections' do
    it 'creates a collections object and returns it' do
      result = typesense.collections

      expect(result).to be_a(Typesense::Collections)
    end
  end

  describe '#debug' do
    it 'creates a debug object and returns it' do
      result = typesense.debug

      expect(result).to be_a(Typesense::Debug)
    end
  end

  describe '#analytics' do
    it 'creates an analytics object and returns it' do
      result = typesense.analytics

      expect(result).to be_a(Typesense::Analytics)
    end
  end

  describe '#analytics_v1' do
    it 'creates an analytics_v1 object and returns it' do
      result = typesense.analytics_v1

      expect(result).to be_a(Typesense::AnalyticsV1)
    end
  end
end
