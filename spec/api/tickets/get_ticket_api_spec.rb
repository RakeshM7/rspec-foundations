# frozen_string_literal: true

# spec/api/tickets/get_ticket_api_spec.rb

require 'spec_helper'

RSpec.describe 'GET /api/v2/tickets', :api do
  let(:ticket) do
    resp = API::TicketClient.create(TicketFactory.build)
    resp.parsed_response['ticket']
  end

  after(:each) { API::TicketClient.destroy(ticket['id']) rescue nil }

  describe 'GET /api/v2/tickets/:id' do
    it 'returns 200 and the ticket', :smoke do
      response = API::TicketClient.find(ticket['id'])

      expect(response.code).to eq(200)
      expect(response.parsed_response.dig('ticket', 'id')).to eq(ticket['id'])
    end

    it 'returns 404 for a non-existent ticket' do
      response = API::TicketClient.find(999_999_999)
      expect(response.code).to eq(404)
    end
  end

  describe 'GET /api/v2/tickets (list)' do
    it 'returns 200 with a tickets array', :smoke do
      response = API::TicketClient.list
      print "Response :: #{response}"
      expect(response.code).to eq(200)
      expect(response.parsed_response).to have_key('tickets')
      expect(response.parsed_response['tickets']).to be_an(Array)
    end

    it 'respects per_page parameter' do
      response = API::TicketClient.list(per_page: 3)
      tickets  = response.parsed_response['tickets']
      expect(tickets.length).to be <= 3
    end
  end

  describe 'Notes (conversations)' do
    it 'adds a note and retrieves it' do
      note_body = "Automated note #{Faker::Number.number(digits: 4)}"
      post_resp = API::TicketClient.add_note(ticket['id'], body: note_body)
      expect(post_resp.code).to eq(201)

      list_resp = API::TicketClient.list_notes(ticket['id'])
      notes     = list_resp.parsed_response['conversations']
      expect(notes.any? { |n| n['body_text']&.include?(note_body) || n['body']&.include?(note_body) }).to be true
    end
  end
end
