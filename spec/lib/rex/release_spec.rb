require 'rails_helper'
require 'rex/release'

RSpec.describe Rex::Release do
  describe '#books' do
    let(:book1) { { "uid1" => { "defaultVersion" => "1.2"} } }
    let(:book2) { { "uid2" => { "defaultVersion" => "1.1"} } }
    let(:data) { { books: book1.merge(book2) } }
    let(:instance) { described_class.new(id: 'id', data: data, config: config) }

    context 'when there is no config data' do
      let(:config) { OpenStruct.new(pipeline_version: nil) }

      it 'does not show a pipeline prefix on IDs' do
        expect(instance.books.map(&:id)).to contain_exactly("uid1@1.2", "uid2@1.1")
      end
    end

    context 'when there is config data do' do
      let(:config) { OpenStruct.new(pipeline_version: 'foo')}

      it 'uses the pipeline as a prefix' do
        expect(instance.books.map(&:id)).to contain_exactly("foo/uid1@1.2", "foo/uid2@1.1")
      end
    end
  end
end
