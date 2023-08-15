require 'rails_helper'

RSpec.describe Api::V0::Bindings::SearchResult do

  let(:raw_os_results_1) {
    {
      took: 4,
      timed_out: false,
      _shards: {
        total: 1,
        successful: 1,
        skipped: 0,
        failed: 0
      },
      hits: {
        total: 1,
        max_score: 11.151909,
        hits: [
          {
            _index: "a31df062-930a-4f46-8953-605711e6d204@b637022_i1",
            _type: "page_element",
            _id: "1c8yCWsBijBxrdvYQcsE",
            _score: 11.151909,
            _source: {
              page_id: "4a4407ed-0969-4018-806f-6ea728d6efb4@",
              element_type: "paragraph",
              page_position: 37
            },
            highlight: {
              visible_content: [
                "In 2006, Pluto was <strong>demoted</strong> to a ‘dwarf planet’ after scientists revised their definition of what constitutes"
              ]
            }
          }
        ]
      }
    }
  }

  it "works" do
    bound = described_class.new.build_from_hash(raw_os_results_1)

    expect(bound.hits).to be_a Api::V0::Bindings::SearchResultHits
    expect(bound.hits.hits[0]._source.element_type).to eq "paragraph"
    expect(bound.hits.hits[0].highlight.visible_content).to include(/dwarf planet/)
  end

end
