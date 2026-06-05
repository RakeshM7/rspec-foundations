# frozen_string_literal: true

# lib/api/problem_client.rb
# Freshservice V2 Problems API client.
# Docs: https://api.freshservice.com/#problems

module API
  class ProblemClient < BaseClient
    RESOURCE_PATH = '/problems'

    def self.resource_key = 'problem'
    def self.list_key     = 'problems'

    def self.list(per_page: 30, page: 1)
      get_resource(RESOURCE_PATH, query: { per_page: per_page, page: page })
    end

    def self.find(id)
      get_resource("#{RESOURCE_PATH}/#{id}")
    end

    def self.create(payload)
      post_resource(RESOURCE_PATH, body: { problem: payload })
    end

    def self.update(id, payload)
      put_resource("#{RESOURCE_PATH}/#{id}", body: { problem: payload })
    end

    def self.destroy(id)
      delete_resource("#{RESOURCE_PATH}/#{id}")
    end

    # ── Sub-resources ─────────────────────────────────────────────────────────

    def self.add_note(problem_id, body:, private: false)
      post_resource("#{RESOURCE_PATH}/#{problem_id}/notes",
                    body: { body: body, private: private })
    end

    # Root cause analysis fields are updated via PUT on the problem itself.
    # This helper makes intent explicit in specs.
    def self.update_analysis(id, root_cause:, symptom:, impact:)
      update(id, {
               root_cause: root_cause,
               symptoms:   symptom,
               impact:     impact
             })
    end
  end
end
