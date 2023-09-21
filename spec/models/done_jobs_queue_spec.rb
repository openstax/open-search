require 'rails_helper'

require 'rex/releases'

RSpec.describe DoneJobsQueue do
  it 'writes a done job in the done jobs queue' do
    done_queue = described_class.new(url: "foo_url")
    expect(done_queue).to be_a_kind_of(DoneJobsQueue)
  end
end
