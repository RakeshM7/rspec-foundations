# frozen_string_literal: true

# lib/api/ticket_client.rb
# Freshservice V2 Tickets API client.
# Docs: https://api.freshservice.com/#tickets
#
# All methods return raw HTTParty::Response objects.
# Specs assert on .code and .parsed_response — never on side-effects.

module API
  class TicketClient < BaseClient
    RESOURCE_PATH = '/tickets'

    # Used by shared_examples 'a CRUD resource' to navigate response hash
    def self.resource_key = 'ticket'
    def self.list_key     = 'tickets'

    # ── CRUD ──────────────────────────────────────────────────────────────────

    def self.list(per_page: 30, page: 1, **filters)
      get_resource(RESOURCE_PATH, query: { per_page: per_page, page: page }.merge(filters))
    end

    def self.find(id)
      get_resource("#{RESOURCE_PATH}/#{id}")
    end

    def self.create(payload)
      post_resource(RESOURCE_PATH, body: { ticket: payload })
    end

    def self.update(id, payload)
      put_resource("#{RESOURCE_PATH}/#{id}", body: { ticket: payload })
    end

    def self.destroy(id)
      delete_resource("#{RESOURCE_PATH}/#{id}")
    end

    # ── Notes / Conversations ─────────────────────────────────────────────────

    def self.add_note(ticket_id, body:, private: false)
      post_resource(
        "#{RESOURCE_PATH}/#{ticket_id}/notes",
        body: { body: body, private: private }
      )
    end

    def self.list_notes(ticket_id)
      get_resource("#{RESOURCE_PATH}/#{ticket_id}/conversations")
    end

    # ── Restore deleted ticket ────────────────────────────────────────────────
    # Freshservice moves deleted tickets to trash; this restores them.
    def self.restore(id)
      put_resource("#{RESOURCE_PATH}/#{id}/restore", body: {})
    end

    # ── Filter helpers ────────────────────────────────────────────────────────
    def self.filter(query_string)
      # Example: query_string = '"status:2 AND priority:1"'
      get_resource("#{RESOURCE_PATH}/filter", query: { query: query_string })
    end
  end
end
