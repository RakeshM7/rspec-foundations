# frozen_string_literal: true

# spec/api/releases/release_crud_api_spec.rb

require 'spec_helper'

RSpec.describe 'Releases API', :api do
  include Allure

  before(:context) do
    Allure.label(:feature, 'Releases API')
    Allure.label(:severity, :normal)
  end

  include_examples 'a CRUD resource', API::ReleaseClient do
    let(:create_payload) { ReleaseFactory.build }
    let(:update_payload) { { status: 3 } }   # 3 = In Progress
  end

  describe 'Release status lifecycle' do
    let(:release) do
      API::ReleaseClient.create(ReleaseFactory.build).parsed_response['release']
    end

    after(:each) { API::ReleaseClient.destroy(release['id']) rescue nil }

    it 'transitions release status from Open to In Progress' do
      response = API::ReleaseClient.update(release['id'], status: 3)
      expect(response.code).to eq(200)
      expect(response.parsed_response.dig('release', 'status')).to eq(3)
    end

    it 'marks release as Completed' do
      response = API::ReleaseClient.update(release['id'], status: 5)
      expect(response.code).to eq(200)
      expect(response.parsed_response.dig('release', 'status')).to eq(5)
    end
  end
end
