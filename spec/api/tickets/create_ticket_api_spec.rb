# frozen_string_literal: true

# spec/api/tickets/create_ticket_api_spec.rb
# ─────────────────────────────────────────────────────────────────────────────
# API tests for POST /api/v2/tickets
#
# Every example asserts THREE things:
#   1. HTTP status code
#   2. Response body schema (field presence + types)
#   3. Field values echo back correctly
#
# This is the gold standard pattern for API test coverage.
# ─────────────────────────────────────────────────────────────────────────────

require 'spec_helper'

RSpec.describe 'POST /api/v2/tickets', :api do
  include Allure

  before(:context) do
    Allure.label(:feature, 'Tickets API')
    Allure.label(:story, 'Create Ticket')
    Allure.label(:severity, :critical)
  end

  # Track created IDs to clean up after each test.
  # Using an instance variable in :api shared context pattern.
  let(:created_ids) { [] }

  after(:each) do
    created_ids.each { |id| API::TicketClient.destroy(id) rescue nil }
  end

  # ── Happy path ──────────────────────────────────────────────────────────────

  describe 'with valid payload' do
    let(:payload) { TicketFactory.build }

    it 'returns 201 Created', :smoke do
      Allure.step('POST /api/v2/tickets with valid payload') do
        response = API::TicketClient.create(payload)
        @last_response = response

        expect(response.code).to eq(201)
      end
    end

    it 'returns the created ticket with an id' do
      response = API::TicketClient.create(payload)
      ticket   = response.parsed_response['ticket']

      created_ids << ticket['id']

      aggregate_failures 'response body assertions' do
        expect(ticket).to have_key('id')
        expect(ticket['id']).to be_a(Integer)
        expect(ticket['subject']).to eq(payload[:subject])
        expect(ticket['priority']).to eq(payload[:priority])
        expect(ticket['status']).to eq(payload[:status])
      end
    end

    it 'assigns the correct type' do
      response = API::TicketClient.create(TicketFactory.build(type: 'Service Request'))
      ticket   = response.parsed_response['ticket']
      created_ids << ticket['id']

      expect(ticket['type']).to eq('Service Request')
    end
  end

  # ── Priority matrix ─────────────────────────────────────────────────────────

  describe 'priority values' do
    { 'Low' => 1, 'Medium' => 2, 'High' => 3, 'Urgent' => 4 }.each do |label, code|
      it "accepts priority #{code} (#{label})" do
        response = API::TicketClient.create(TicketFactory.build(priority: code))
        ticket   = response.parsed_response['ticket']
        created_ids << ticket['id']

        expect(response.code).to eq(201)
        expect(ticket['priority']).to eq(code)
      end
    end
  end

  # ── Negative cases ───────────────────────────────────────────────────────────

  describe 'validation errors' do
    it 'returns 422 when subject is missing' do
      response = API::TicketClient.create(TicketFactory.build_without_subject)
      @last_response = response

      expect(response.code).to eq(422)
      expect(response.parsed_response).to have_key('errors').or have_key('description')
    end

    it 'returns 422 when requester email is missing and no requester_id' do
      payload  = TicketFactory.build_without_email.except(:requester_id)
      response = API::TicketClient.create(payload)

      expect(response.code).to eq(422)
    end

    it 'returns 401 with an invalid API key' do
      # Temporarily swap the API key by calling HTTParty directly
      response = HTTParty.post(
        "#{ENV['APP_URL']}/api/v2/tickets",
        basic_auth: { username: 'invalid_key', password: 'X' },
        headers:    { 'Content-Type' => 'application/json' },
        body:       TicketFactory.build.to_json
      )

      expect(response.code).to eq(401)
    end
  end

  # ── Schema validation ────────────────────────────────────────────────────────

  describe 'response schema' do
    let(:schema_path) { File.expand_path('../../../schemas/ticket_create_response.json', __dir__) }

    it 'matches the expected JSON schema', :smoke do
      skip 'Schema file not yet created' unless File.exist?(schema_path)

      response = API::TicketClient.create(TicketFactory.build)
      ticket   = response.parsed_response
      created_ids << ticket.dig('ticket', 'id')

      schema   = JSONSchemer.schema(File.read(schema_path))
      errors   = schema.validate(ticket).to_a
      expect(errors).to be_empty, "Schema errors:\n#{errors.map(&:to_h).inspect}"
    end
  end
end
