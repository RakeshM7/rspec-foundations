# frozen_string_literal: true

# spec/support/shared_examples/api_crud.rb
#
# Reusable CRUD contract shared across all four TPCR entities.
# Usage in a spec:
#
#   it_behaves_like 'a CRUD resource', TicketClient, TicketFactory do
#     let(:create_payload) { TicketFactory.build }
#     let(:update_payload) { { priority: 2 } }
#   end
#
# WHY shared_examples?
# Ticket, Problem, Change, Release all expose the same REST contract.
# Writing identical create/read/update/delete tests four times is
# duplication. shared_examples runs the same examples against each client.
# If the contract changes, one edit fixes all four.

RSpec.shared_examples 'a CRUD resource' do |client_class|
  let(:created_id) { nil }

  describe 'POST (create)' do
    it 'returns 201 and the created resource', :api do
      response = client_class.create(create_payload)
      expect(response.code).to eq(201)
      expect(response.parsed_response).to have_key('id').or have_key(client_class.resource_key)
    end
  end

  describe 'GET (read)' do
    it 'returns 200 and the resource by id', :api do
      create_response = client_class.create(create_payload)
      id = create_response.parsed_response.dig(client_class.resource_key, 'id')

      response = client_class.find(id)
      expect(response.code).to eq(200)
      expect(response.parsed_response.dig(client_class.resource_key, 'id')).to eq(id)
    end

    it 'returns 404 for a non-existent id', :api do
      response = client_class.find(999_999_999)
      expect(response.code).to eq(404)
    end
  end

  describe 'PUT (update)' do
    it 'returns 200 and reflects the change', :api do
      id = client_class.create(create_payload).parsed_response.dig(client_class.resource_key, 'id')

      response = client_class.update(id, update_payload)
      expect(response.code).to eq(200)

      update_payload.each do |key, val|
        expect(response.parsed_response.dig(client_class.resource_key, key.to_s)).to eq(val)
      end
    end
  end

  describe 'DELETE' do
    it 'returns 204 and removes the resource', :api do
      id = client_class.create(create_payload).parsed_response.dig(client_class.resource_key, 'id')

      delete_response = client_class.destroy(id)
      expect(delete_response.code).to eq(204)

      get_response = client_class.find(id)
      expect(get_response.code).to eq(404)
    end
  end
end

RSpec.shared_examples 'a paginated list endpoint' do |client_class|
  it 'returns page metadata', :api do
    response = client_class.list(per_page: 5, page: 1)
    expect(response.code).to eq(200)
    body = response.parsed_response
    # Freshservice V2 list responses wrap results in the resource key
    expect(body).to include(client_class.resource_key.to_s)
  end

  it 'respects per_page param', :api do
    response = client_class.list(per_page: 2, page: 1)
    results  = response.parsed_response[client_class.list_key.to_s]
    expect(results.length).to be <= 2
  end
end
