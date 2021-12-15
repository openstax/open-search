require 'rails_helper'
require 'rex/release'

RSpec.describe Rex::Release do
  describe '#books' do
    let(:book1) { { "uid1" => { "defaultVersion" => "1.2"} } }
    let(:book2) { { "uid2" => { "defaultVersion" => "1.1"} } }
    let(:book3) { { "uid3" => { "defaultVersion" => "1.3", "archiveOverride" => "/apps/archive/20210713.205645"} } }
    let(:data) { { books: book1.merge(book2).merge(book3) } }
    let(:instance) { described_class.new(id: 'id', data: data, config: config) }

    context 'when there is no config data' do
      let(:config) { OpenStruct.new(pipeline: nil) }

      it 'has the right number of books' do
        expect(instance.books.length).to equal(3)
      end

      it 'does not show config pipeline prefix on IDs' do
        expect(instance.books.map(&:id)).to include("uid1@1.2", "uid2@1.1")
      end

      it 'shows overrid pipeline prefix on IDs' do
        expect(instance.books.map(&:id)).to include("20210713.205645/uid3@1.3")
      end
    end

    context 'when there is config data do' do
      let(:config) { OpenStruct.new(pipeline: 'foo')}

      it 'has the right number of books' do
        expect(instance.books.length).to equal(3)
      end

      it 'uses the config pipeline as a prefix' do
        expect(instance.books.map(&:id)).to include("foo/uid1@1.2", "foo/uid2@1.1")
      end

      it 'uses the archive override as pipeline in the prefix' do
        expect(instance.books.map(&:id)).to include("20210713.205645/uid3@1.3")
      end
    end
  end
end
