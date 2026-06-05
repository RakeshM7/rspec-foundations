# frozen_string_literal: true

# spec/ui/tickets/create_ticket_spec.rb
# ─────────────────────────────────────────────────────────────────────────────
# UI tests for the Create Ticket flow.
#
# Tags used:
#   :ui  — triggers 'with authenticated session' shared context (auto-login)
#   :js  — activates the Selenium driver + rspec-retry + screenshot-on-failure
#   :smoke — included in the smoke suite run on every PR
# ─────────────────────────────────────────────────────────────────────────────

require 'spec_helper'

RSpec.describe 'Create Ticket UI', :ui, :js do
  # Allure suite metadata — shown in the Allure feature hierarchy
  include Allure

  before(:context) do
    Allure.label(:feature, 'Ticket Management')
    Allure.label(:story, 'Create Ticket')
  end

  # Page objects — instantiated per context, not per example.
  # WHY let not let!: page objects don't need to exist before the example starts.
  let(:list_page) { Pages::Tickets::TicketListPage.new }
  let(:form_page) { Pages::Tickets::TicketFormPage.new }

  # Unique subject prevents false positives if a previous run left the same record.
  let(:subject_text) { "UI Test Ticket #{Faker::Number.unique.number(digits: 6)}" }

  describe 'Happy path — create a valid Incident ticket', :smoke do
    it 'creates the ticket and shows it in the ticket list' do
      Allure.step('Navigate to ticket list') do
        list_page.load
        expect(list_page).to be_loaded
      end

      Allure.step('Open new ticket form') do
        list_page.open_new_form
        expect(form_page).to be_loaded
      end

      Allure.step('Fill in required fields') do
        form_page.fill_and_submit(
          subject:     subject_text,
          description: 'Created by automated UI test',
          email:       Faker::Internet.email,
          priority:    'Medium',
          type:        'Incident'
        )
      end

      Allure.step('Verify redirect to ticket show page') do
        # After successful submit, Freshservice redirects to the new ticket's show page.
        expect(page.current_url).to match(%r{/helpdesk/tickets/\d+})
        expect(page).to have_content(subject_text)
      end
    end
  end

  describe 'Validation — required fields' do
    it 'shows an error when subject is blank' do
      Allure.step('Submit form without a subject') do
        list_page.load
        list_page.open_new_form
        form_page.fill_and_submit(subject: '', email: Faker::Internet.email)
      end

      Allure.step('Verify validation error is shown') do
        expect(page).to have_css('.error, .invalid-feedback', wait: 5)
        expect(page.current_url).not_to match(%r{/helpdesk/tickets/\d+})
      end
    end
  end

  describe 'Priority selection' do
    %w[Low Medium High Urgent].each do |priority|
      it "creates a #{priority} priority ticket" do
        list_page.load
        list_page.open_new_form
        form_page.fill_and_submit(
          subject:  "#{priority} priority test #{Faker::Number.number(digits: 4)}",
          email:    Faker::Internet.email,
          priority: priority
        )
        expect(page.current_url).to match(%r{/helpdesk/tickets/\d+})
      end
    end
  end
end
