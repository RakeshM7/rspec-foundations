# frozen_string_literal: true

# lib/api/change_client.rb
# Freshservice V2 Changes API client.
# Docs: https://api.freshservice.com/#changes
#
# Change types: 1=Minor, 2=Standard, 3=Major, 4=Emergency
# Change risk:  1=Low, 2=Medium, 3=High, 4=Very High
# Change status: 1=Open, 2=Planning, 3=Awaiting Approval, 4=Pending Review,
#                5=Awaiting CAB approval, 6=Scheduled, 7=Implementing,
#                8=Review, 9=Close, 10=Cancelled

module API
  class ChangeClient < BaseClient
    RESOURCE_PATH = '/changes'

    def self.resource_key = 'change'
    def self.list_key     = 'changes'

    def self.list(per_page: 30, page: 1)
      get_resource(RESOURCE_PATH, query: { per_page: per_page, page: page })
    end

    def self.find(id)
      get_resource("#{RESOURCE_PATH}/#{id}")
    end

    def self.create(payload)
      post_resource(RESOURCE_PATH, body: { change: payload })
    end

    def self.update(id, payload)
      put_resource("#{RESOURCE_PATH}/#{id}", body: { change: payload })
    end

    def self.destroy(id)
      delete_resource("#{RESOURCE_PATH}/#{id}")
    end

    # ── Approvals sub-resource ────────────────────────────────────────────────
    # GET all approval requests for a change
    def self.list_approvals(change_id)
      get_resource("#{RESOURCE_PATH}/#{change_id}/approvals")
    end

    # Create an approval request (triggers notifications to approvers)
    def self.create_approval(change_id, approver_id:)
      post_resource(
        "#{RESOURCE_PATH}/#{change_id}/approvals",
        body: { approval_request: { approver_id: approver_id } }
      )
    end

    # ── Notes ─────────────────────────────────────────────────────────────────
    def self.add_note(change_id, body:, private: false)
      post_resource("#{RESOURCE_PATH}/#{change_id}/notes",
                    body: { body: body, private: private })
    end
  end
end
