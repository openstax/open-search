require 'rails_helper'
require 'vcr_helper'

RSpec.describe Books::IndexingStrategies::I3::PageDocument, vcr: VCR_OPTS do
  let(:pipeline)  { '20230620.181811' }
  let(:book_uuid) { 'a31df062-930a-4f46-8953-605711e6d204' }
  let(:version)   { 'ccb5581' }

  let(:book) { Book.new(pipeline: pipeline, uuid: book_uuid, version: version) }
  let(:page) { book.root_book_part.pages.first }

  subject(:page_document) { described_class.new(page: page) }

  describe "#body" do
    it 'builds a body structure' do
      expect(page_document.body).to be_a(Hash)
    end
  end

  describe ".mapping" do
    it 'builds the page properties' do
      expect(described_class.mapping).to include(:contextTitle)
    end
  end

  describe "#initialize" do
    it 'will create a valid object' do
      expect(page_document).to be_a_kind_of(described_class)
    end
  end
end
