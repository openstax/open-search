require 'rails_helper'

RSpec.describe ApiV0Helpers, api: :v0 do

  context '#prep_request_args' do
    it "prepends '/api/v0' to the first argument" do
      expect(prep_request_args(['some_path'], {})[0]).to eq '/api/v0/some_path'
    end

    it 'adds default headers if none set' do
      kwargs = {}
      prep_request_args(['blah'], kwargs)
      expect(kwargs[:headers]).to include('CONTENT_TYPE' => 'application/json')
    end

    it 'adds headers if some set' do
      kwargs = { headers: { 'foo' => 'bar' } }
      prep_request_args(['blah'], kwargs)
      expect(kwargs[:headers]).to include('CONTENT_TYPE' => 'application/json')
      expect(kwargs[:headers]).to include('foo' => 'bar')
    end
  end

end
