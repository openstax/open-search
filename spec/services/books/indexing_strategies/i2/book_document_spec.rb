require 'rails_helper'
require 'vcr_helper'

RSpec.describe Books::IndexingStrategies::I2::BookDocument, vcr: VCR_OPTS do
  let(:pipeline) { '20230620.181811' }
  let(:uuid)     { 'a31df062-930a-4f46-8953-605711e6d204' }
  let(:version)  { 'ccb5581' }

  let(:book) { Book.new(pipeline: pipeline, uuid: uuid, version: version) }

  subject(:book_document) { described_class.new(book: book) }

  describe "#body" do
    it 'builds a body structure' do
      expect(book_document.body).to be_a(Hash)
    end
  end

  describe ".mapping" do
    it 'builds the book properties' do
      expect(described_class.mapping).to include(:title)
    end
  end

  describe "#initialize" do
    it 'will create a valid object' do
      expect(book_document).to be_a_kind_of(described_class)
    end
  end
end
