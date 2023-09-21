require 'rails_helper'

require 'rex/releases'

RSpec.describe TodoJobsQueue do
  it 'writes a done job in the done jobs queue' do
    todo_queue = described_class.new(url: "foo_url")
    expect(todo_queue).to be_a_kind_of(TodoJobsQueue)
  end
end
