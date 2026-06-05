# frozen_string_literal: true

# spec/ui/changes/change_approval_spec.rb
# Demonstrates a multi-step workflow test — the most complex UI scenario.

require 'spec_helper'

RSpec.describe 'Change Approval Workflow', :ui, :js do
  let(:change_data) do
    resp = API::ChangeClient.create(ChangeFactory.build)
    expect(resp.code).to eq(201), "API setup failed: #{resp.body}"
    resp.parsed_response['change']
  end

  after(:each) { API::ChangeClient.destroy(change_data['id']) rescue nil }

  it 'moves a change through the approval workflow stages', :smoke do
    visit "#{ENV['APP_URL']}/itil/changes/#{change_data['id']}"

    # Stage 1: Submit for planning
    Allure.step('Move change to Planning status') do
      find('[data-field="status"] .dropdown-toggle').click
      find('[role="option"], .dropdown-item', text: 'Planning', wait: 5).click
      expect(page).to have_css('[data-testid="status-label"]', text: /Planning/i, wait: 10)
    end

    # Stage 2: Submit for approval
    Allure.step('Submit change for approval') do
      find('button, a', text: /Submit for Approval/i, wait: 5).click
      page.accept_confirm rescue nil
      expect(page).to have_css('[data-testid="status-label"]', text: /Approval/i, wait: 10)
    end
  end
end
