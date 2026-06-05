# frozen_string_literal: true

# spec/api/problems/problem_crud_api_spec.rb

require 'spec_helper'

RSpec.describe 'Problems API', :api do
  include Allure

  before(:context) do
    Allure.label(:feature, 'Problems API')
    Allure.label(:severity, :normal)
  end

  include_examples 'a CRUD resource', API::ProblemClient do
    let(:create_payload) { ProblemFactory.build }
    let(:update_payload) { { priority: 3 } }
  end

  describe 'Root cause analysis update' do
    let(:problem) do
      API::ProblemClient.create(ProblemFactory.build).parsed_response['problem']
    end

    after(:each) { API::ProblemClient.destroy(problem['id']) rescue nil }

    it 'updates root cause, symptom, and impact fields' do
      response = API::ProblemClient.update_analysis(
        problem['id'],
        root_cause: 'Database connection pool exhausted',
        symptom:    'Timeouts on all ticket list pages',
        impact:     'All agents unable to view tickets'
      )

      expect(response.code).to eq(200)
      p = response.parsed_response['problem']
      expect(p['root_cause']).to include('Database')
    end
  end
end
