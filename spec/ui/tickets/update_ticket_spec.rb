# frozen_string_literal: true

# spec/ui/tickets/update_ticket_spec.rb

require 'spec_helper'

RSpec.describe 'Update Ticket UI', :ui, :js do
  let(:api_ticket) do
    # Use the API to create test data — faster and more reliable than UI setup.
    # WHY: UI setup in before(:each) is slow and creates fragile test ordering.
    # API creates the fixture, UI tests the behavior. This is the correct split.
    resp = API::TicketClient.create(TicketFactory.build)
    expect(resp.code).to eq(201), "API setup failed: #{resp.body}"
    resp.parsed_response['ticket']
  end

  let(:show_page) { Pages::Tickets::TicketShowPage.new }

  before(:each) do
    # Navigate directly to the ticket created via API
    visit "#{ENV['APP_URL']}/helpdesk/tickets/#{api_ticket['id']}"
    expect(show_page).to be_loaded
  end

  after(:each) do
    # Cleanup: delete via API so each test starts clean.
    API::TicketClient.destroy(api_ticket['id']) rescue nil
  end

  describe 'Status transitions' do
    it 'changes ticket status from Open to Pending' do
      Allure.step('Change status to Pending') do
        show_page.change_status_to('Pending')
      end

      Allure.step('Verify status badge updates') do
        expect(show_page.status_badge.text).to match(/Pending/i)
      end
    end

    it 'changes ticket status from Open to Resolved' do
      show_page.change_status_to('Resolved')
      expect(show_page.status_badge.text).to match(/Resolved/i)
    end
  end

  describe 'Add a reply' do
    it 'submits a reply and shows it in the activity timeline' do
      reply_text = "Automated reply #{Faker::Number.number(digits: 4)}"

      show_page.add_reply(reply_text)

      expect(page).to have_content(reply_text, wait: 10)
    end
  end
end
