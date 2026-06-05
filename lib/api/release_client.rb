# frozen_string_literal: true

# lib/api/release_client.rb
# Freshservice V2 Releases API client.
# Docs: https://api.freshservice.com/#releases
#
# Release status: 1=Open, 2=On hold, 3=In progress, 4=Incomplete, 5=Completed
# Release type:   1=Minor, 2=Standard, 3=Major, 4=Emergency

module API
  class ReleaseClient < BaseClient
    RESOURCE_PATH = '/releases'

    def self.resource_key = 'release'
    def self.list_key     = 'releases'

    def self.list(per_page: 30, page: 1)
      get_resource(RESOURCE_PATH, query: { per_page: per_page, page: page })
    end

    def self.find(id)
      get_resource("#{RESOURCE_PATH}/#{id}")
    end

    def self.create(payload)
      post_resource(RESOURCE_PATH, body: { release: payload })
    end

    def self.update(id, payload)
      put_resource("#{RESOURCE_PATH}/#{id}", body: { release: payload })
    end

    def self.destroy(id)
      delete_resource("#{RESOURCE_PATH}/#{id}")
    end

    # ── Notes ─────────────────────────────────────────────────────────────────
    def self.add_note(release_id, body:, private: false)
      post_resource("#{RESOURCE_PATH}/#{release_id}/notes",
                    body: { body: body, private: private })
    end
  end
end
