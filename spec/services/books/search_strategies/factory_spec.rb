require 'rails_helper'

RSpec.describe Books::SearchStrategies::Factory do
  let(:index_ids) { ['foo@1.1'] }

  subject(:factory) {
    described_class.build(index_ids: index_ids,
                          index_strategies: index_strategies,
                          search_strategy: search_strategy)
  }

  describe ".build" do
    let(:index_strategies) { %w(i1 i2 i3) }
    let(:search_strategy)  { 's1' }

    it 'creates the strategy' do
      expect(factory).to be_kind_of(Books::SearchStrategies::S1::Strategy)
    end

    context 'unknown strategy' do
      let(:search_strategy) { 's_foo' }

      it 'pulls out the caption from the figure' do
        expect { factory }.to raise_error(Books::SearchStrategies::UnknownSearchStrategy)
      end
    end

    context 'incompatible strategy' do
      let(:index_strategies) { %w(i_foo) }

      it 'pulls out the caption from the figure' do
        expect { factory }.to raise_error(Books::SearchStrategies::IncompatibleStrategies)
      end
    end
  end
end
