# frozen_string_literal: true

# spec/api/tickets/ticket_crud_api_spec.rb
# Full CRUD cycle via shared_examples

require 'spec_helper'

RSpec.describe 'Tickets API — CRUD', :api do
  include_examples 'a CRUD resource', API::TicketClient do
    let(:create_payload) { TicketFactory.build }
    let(:update_payload) { { priority: 3, status: 2 } }
  end

  include_examples 'a paginated list endpoint', API::TicketClient
end
