require 'rails_helper'

RSpec.describe Api::V0::Bindings::SearchResult do
  let(:raw_element_results) {
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

  let(:raw_book_results) {
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
        max_score: 2,
        hits: [
          {
            _index: "v4__c3558e1_i2",
            _id: "031da8d3-b525-429c-80cf-6c8ed997733a",
            _score: 2,
            _source: {
              id: "031da8d3-b525-429c-80cf-6c8ed997733a",
              orn: "https://openstax.org/orn/book/031da8d3-b525-429c-80cf-6c8ed997733a",
              versionedOrn: "https://openstax.org/orn/book/031da8d3-b525-429c-80cf-6c8ed997733a",
              type: "book",
              state: "retired",
              title: "College Physics",
              language: "en",
              slug: "college-physics",
              default_page: {
                id: "1d1fd537-77fb-4eac-8a8a-60bbaa747b6d",
                title: '<span data-type="" itemprop="" class="os-text">Introduction to Science and the Realm of Physics, Physical Quantities, and Units</span>',
                titleParts: {
                  html: '<span data-type="" itemprop="" class="os-text">Introduction to Science and the Realm of Physics, Physical Quantities, and Units</span>',
                  numberText: nil,
                  title: "Introduction to Science and the Realm of Physics, Physical Quantities, and Units",
                  shortTitle: "Introduction to Science and the Realm of Physics, Physical Quantities, and Units"
                },
                orn: "https://openstax.org/orn/book:page/031da8d3-b525-429c-80cf-6c8ed997733a:1d1fd537-77fb-4eac-8a8a-60bbaa747b6d",
                versionedOrn: "https://openstax.org/orn/book:page/031da8d3-b525-429c-80cf-6c8ed997733a:1d1fd537-77fb-4eac-8a8a-60bbaa747b6d",
                slug: "1-introduction-to-science-and-the-realm-of-physics-physical-quantities-and-units",
                type: "book:page",
                tocType: "book-content",
                tocTargetType: "intro"
              },
              theme: "blue",
              license: {
                holder: "OpenStax",
                name: "Creative Commons Attribution License",
                url: "http://creativecommons.org/licenses/by/4.0/"
              },
              urls: {
                main: "https://openstax.org/details/books/college-physics",
                information: "https://openstax.org/details/books/college-physics",
                experience: "https://openstax.org/books/college-physics/pages/1-introduction-to-science-and-the-realm-of-physics-physical-quantities-and-units"
              },
              images: {
                main: "https://assets.openstax.org/oscms-prodcms/media/documents/physics.svg",
                square: "https://assets.openstax.org/oscms-prodcms/media/documents/physics.svg",
                wide: "https://assets.openstax.org/oscms-prodcms/media/documents/Head_CollegePhysics.svg",
                promotional: "https://assets.openstax.org/oscms-prodcms/media/original_images/CollegePhysics.jpeg"
              },
              contents: [
                {
                  id: "a4579e90-f894-4438-88c3-14772d3da9ff",
                  title: '<span data-type="" itemprop="" class="os-text">Preface</span>',
                  titleParts: {
                    html: '<span data-type="" itemprop="" class="os-text">Preface</span>',
                    numberText: nil,
                    title: "Preface",
                    shortTitle: "Preface"
                  },
                  orn: "https://openstax.org/orn/book:page/031da8d3-b525-429c-80cf-6c8ed997733a:a4579e90-f894-4438-88c3-14772d3da9ff",
                  versionedOrn: "https://openstax.org/orn/book:page/031da8d3-b525-429c-80cf-6c8ed997733a:a4579e90-f894-4438-88c3-14772d3da9ff",
                  slug: "preface",
                  type: "book:page",
                  tocType: "book-content",
                  tocTargetType: "preface"
                },
                {
                  id: "e4cd9bdf-413b-5adf-9a29-ce77cd9bf486",
                  title: '<span class="os-number"><span class="os-part-text">Chapter </span>1</span>
                      <span class="os-divider"> </span>
                      <span class="os-text" data-type="" itemprop="">Introduction: The Nature of Science and Physics</span>',
                  titleParts: {
                    html: '<span class="os-number"><span class="os-part-text">Chapter </span>1</span>
                        <span class="os-divider"> </span>
                        <span class="os-text" data-type="" itemprop="">Introduction: The Nature of Science and Physics</span>',
                    number: "1",
                    numberText: "Chapter 1",
                    title: "Chapter 1 Introduction: The Nature of Science and Physics",
                    shortTitle: "Introduction: The Nature of Science and Physics"
                  },
                  default_page: {
                    id: "1d1fd537-77fb-4eac-8a8a-60bbaa747b6d",
                    title: '<span data-type="" itemprop="" class="os-text">Introduction to Science and the Realm of Physics, Physical Quantities, and Units</span>',
                    titleParts: {
                      html: '<span data-type="" itemprop="" class="os-text">Introduction to Science and the Realm of Physics, Physical Quantities, and Units</span>',
                      numberText: nil,
                      title: "Introduction to Science and the Realm of Physics, Physical Quantities, and Units",
                      shortTitle: "Introduction to Science and the Realm of Physics, Physical Quantities, and Units"
                    },
                    orn: "https://openstax.org/orn/book:page/031da8d3-b525-429c-80cf-6c8ed997733a:1d1fd537-77fb-4eac-8a8a-60bbaa747b6d",
                    versionedOrn: "https://openstax.org/orn/book:page/031da8d3-b525-429c-80cf-6c8ed997733a:1d1fd537-77fb-4eac-8a8a-60bbaa747b6d",
                    slug: "1-introduction-to-science-and-the-realm-of-physics-physical-quantities-and-units",
                    type: "book:page",
                    tocType: "book-content",
                    tocTargetType: "intro"
                  },
                  orn: "https://openstax.org/orn/book:subbook/031da8d3-b525-429c-80cf-6c8ed997733a:e4cd9bdf-413b-5adf-9a29-ce77cd9bf486",
                  versionedOrn: "https://openstax.org/orn/book:subbook/031da8d3-b525-429c-80cf-6c8ed997733a:e4cd9bdf-413b-5adf-9a29-ce77cd9bf486",
                  type: "book:subbook",
                  tocType: "chapter",
                  contents: [
                    {
                      id: "1d1fd537-77fb-4eac-8a8a-60bbaa747b6d",
                      title: '<span data-type="" itemprop="" class="os-text">Introduction to Science and the Realm of Physics, Physical Quantities, and Units</span>',
                      titleParts: {
                        html: '<span data-type="" itemprop="" class="os-text">Introduction to Science and the Realm of Physics, Physical Quantities, and Units</span>',
                        numberText: nil,
                        title: "Introduction to Science and the Realm of Physics, Physical Quantities, and Units",
                        shortTitle: "Introduction to Science and the Realm of Physics, Physical Quantities, and Units"
                      },
                      orn: "https://openstax.org/orn/book:page/031da8d3-b525-429c-80cf-6c8ed997733a:1d1fd537-77fb-4eac-8a8a-60bbaa747b6d",
                      versionedOrn: "https://openstax.org/orn/book:page/031da8d3-b525-429c-80cf-6c8ed997733a:1d1fd537-77fb-4eac-8a8a-60bbaa747b6d",
                      slug: "1-introduction-to-science-and-the-realm-of-physics-physical-quantities-and-units",
                      type: "book:page",
                      tocType: "book-content",
                      tocTargetType: "intro"
                    }
                  ]
                }
              ]
            }
          }
        ]
      }
    }
  }

  let(:raw_page_results) {
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
        max_score: 3,
        hits: [
          {
            _index: "v4__c3558e1_i3",
            _id: "1d1fd537-77fb-4eac-8a8a-60bbaa747b6d",
            _score: 3,
            _source: {
              id: "1d1fd537-77fb-4eac-8a8a-60bbaa747b6d",
              title: "Introduction to Science and the Realm of Physics, Physical Quantities, and Units",
              titleParts: {
                html: '<span data-type="" itemprop="" class="os-text">Introduction to Science and the Realm of Physics, Physical Quantities, and Units</span>',
                numberText: nil,
                title: "Introduction to Science and the Realm of Physics, Physical Quantities, and Units",
                shortTitle: "Introduction to Science and the Realm of Physics, Physical Quantities, and Units"
              },
              orn: "https://openstax.org/orn/book:page/031da8d3-b525-429c-80cf-6c8ed997733a:1d1fd537-77fb-4eac-8a8a-60bbaa747b6d",
              versionedOrn: "https://openstax.org/orn/book:page/031da8d3-b525-429c-80cf-6c8ed997733a:1d1fd537-77fb-4eac-8a8a-60bbaa747b6d",
              slug: "1-introduction-to-science-and-the-realm-of-physics-physical-quantities-and-units",
              type: "book:page",
              tocType: "book-content",
              tocTargetType: "intro",
              context: {},
              contextTitle: "College Physics / Chapter 1 / Introduction to Science and the Realm of Physics, Physical Quantities, and Units",
              contextTitles: [
                "College Physics",
                "Chapter 1 Introduction: The Nature of Science and Physics",
                "Introduction to Science and the Realm of Physics, Physical Quantities, and Units"
              ],
              book: {
                id: "031da8d3-b525-429c-80cf-6c8ed997733a",
                orn: "https://openstax.org/orn/book/031da8d3-b525-429c-80cf-6c8ed997733a",
                versionedOrn: "https://openstax.org/orn/book/031da8d3-b525-429c-80cf-6c8ed997733a",
                type: "book",
                state: "retired",
                title: "College Physics",
                language: "en",
                slug: "college-physics",
                default_page: {
                  id: "1d1fd537-77fb-4eac-8a8a-60bbaa747b6d",
                  title: '<span data-type="" itemprop="" class="os-text">Introduction to Science and the Realm of Physics, Physical Quantities, and Units</span>',
                  titleParts: {
                    html: '<span data-type="" itemprop="" class="os-text">Introduction to Science and the Realm of Physics, Physical Quantities, and Units</span>',
                    numberText: nil,
                    title: "Introduction to Science and the Realm of Physics, Physical Quantities, and Units",
                    shortTitle: "Introduction to Science and the Realm of Physics, Physical Quantities, and Units"
                  },
                  orn: "https://openstax.org/orn/book:page/031da8d3-b525-429c-80cf-6c8ed997733a:1d1fd537-77fb-4eac-8a8a-60bbaa747b6d",
                  versionedOrn: "https://openstax.org/orn/book:page/031da8d3-b525-429c-80cf-6c8ed997733a:1d1fd537-77fb-4eac-8a8a-60bbaa747b6d",
                  slug: "1-introduction-to-science-and-the-realm-of-physics-physical-quantities-and-units",
                  type: "book:page",
                  tocType: "book-content",
                  tocTargetType: "intro"
                },
                theme: "blue",
                license: {
                  holder: "OpenStax",
                  name: "Creative Commons Attribution License",
                  url: "http://creativecommons.org/licenses/by/4.0/"
                },
                urls: {
                  main: "https://openstax.org/details/books/college-physics",
                  information: "https://openstax.org/details/books/college-physics",
                  experience: "https://openstax.org/books/college-physics/pages/1-introduction-to-science-and-the-realm-of-physics-physical-quantities-and-units"
                },
                images: {
                  main: "https://assets.openstax.org/oscms-prodcms/media/documents/physics.svg",
                  square: "https://assets.openstax.org/oscms-prodcms/media/documents/physics.svg",
                  wide: "https://assets.openstax.org/oscms-prodcms/media/documents/Head_CollegePhysics.svg",
                  promotional: "https://assets.openstax.org/oscms-prodcms/media/original_images/CollegePhysics.jpeg"
                }
              },
              urls: {
                main: "https://openstax.org/books/college-physics/pages/1-introduction-to-science-and-the-realm-of-physics-physical-quantities-and-units",
                experience: "https://openstax.org/books/college-physics/pages/1-introduction-to-science-and-the-realm-of-physics-physical-quantities-and-units"
              }
            }
          }
        ]
      }
    }
  }

  # Swagger-blocks does not bind _source because of oneOf in the schema

  it "works for elements" do
    bound = described_class.new.build_from_hash(raw_element_results)

    expect(bound.hits).to be_a Api::V0::Bindings::SearchResultHits
    expect(bound.hits.hits[0]._source[:element_type]).to eq 'paragraph'
    expect(bound.hits.hits[0]._source).to eq raw_element_results[:hits][:hits][0][:_source]
    expect(bound.hits.hits[0].highlight.visible_content).to include(/dwarf planet/)
  end

  it "works for books" do
    bound = described_class.new.build_from_hash(raw_book_results)

    expect(bound.hits).to be_a Api::V0::Bindings::SearchResultHits
    expect(bound.hits.hits[0]._source[:title]).to eq 'College Physics'
    expect(bound.hits.hits[0]._source).to eq raw_book_results[:hits][:hits][0][:_source]
  end

  it "works for pages" do
    bound = described_class.new.build_from_hash(raw_page_results)

    expect(bound.hits).to be_a Api::V0::Bindings::SearchResultHits
    expect(bound.hits.hits[0]._source[:contextTitle]).to eq(
      'College Physics / Chapter 1 / Introduction to Science and the Realm of Physics, Physical Quantities, and Units'
    )
    expect(bound.hits.hits[0]._source).to eq raw_page_results[:hits][:hits][0][:_source]
  end
end
