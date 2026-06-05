# frozen_string_literal: true

# spec/api/changes/change_crud_api_spec.rb

require 'spec_helper'

RSpec.describe 'Changes API', :api do
  include Allure

  before(:context) do
    Allure.label(:feature, 'Changes API')
    Allure.label(:severity, :critical)
  end

  include_examples 'a CRUD resource', API::ChangeClient do
    let(:create_payload) { ChangeFactory.build }
    let(:update_payload) { { priority: 3, risk: 2 } }
  end

  describe 'Change types' do
    after(:each) { API::ChangeClient.destroy(@change_id) rescue nil }

    [['Minor', 1], ['Standard', 2], ['Major', 3], ['Emergency', 4]].each do |type_label, type_code|
      it "creates a #{type_label} change (type=#{type_code})" do
        response  = API::ChangeClient.create(ChangeFactory.build(change_type: type_code))
        change    = response.parsed_response['change']
        @change_id = change['id']

        expect(response.code).to eq(201)
        expect(change['change_type']).to eq(type_code)
      end
    end
  end

  describe 'Approvals sub-resource' do
    let(:change) do
      API::ChangeClient.create(ChangeFactory.build).parsed_response['change']
    end

    after(:each) { API::ChangeClient.destroy(change['id']) rescue nil }

    it 'lists approvals for a change' do
      response = API::ChangeClient.list_approvals(change['id'])
      expect(response.code).to eq(200)
    end
  end
end
