# frozen_string_literal: true

# lib/pages/tickets/ticket_show_page.rb

module Pages
  module Tickets
    class TicketShowPage < BasePage
      # URL is dynamic — SitePrism matches /helpdesk/tickets/\d+
      set_url_matcher(%r{/helpdesk/tickets/\d+})

      load_validation { has_css?('.ticket-content, #ticket-details', wait: 10) }

      # Header / metadata
      element :ticket_id,       '.ticket-id, [data-testid="ticket-id"]'
      element :ticket_subject,  '.ticket-subject, h2.subject'
      element :status_badge,    '.status-badge, [data-testid="status-label"]'
      element :priority_badge,  '.priority-badge, [data-testid="priority-label"]'

      # Actions
      element :edit_button,     '.edit-ticket, a[href*="edit"]'
      element :delete_button,   'a[data-confirm], button.delete-ticket'
      element :status_dropdown, '.change-status, [data-field="status"] .dropdown-toggle'
      element :reply_box,       '.reply-editor, [contenteditable][class*="reply"]'
      element :send_reply_btn,  'button.send-reply, input[value="Send"]'

      # Activity timeline
      elements :activity_entries, '.activity-entry, [data-type="activity"]'

      # ── Actions ────────────────────────────────────────────────────────────

      def change_status_to(label)
        select_from_dropdown('.change-status, [data-field="status"] .dropdown-toggle', label)
        wait_for_page_ready
      end

      def delete!
        delete_button.click
        page.accept_confirm
        wait_for_page_ready
      end

      def add_reply(text)
        reply_box.click
        reply_box.send_keys(text)
        send_reply_btn.click
      end
    end
  end
end
