# frozen_string_literal: true

# lib/pages/tickets/ticket_form_page.rb
#
# Covers both the New Ticket form and the Edit Ticket form.
# Freshservice uses the same component for both.

module Pages
  module Tickets
    class TicketFormPage < BasePage
      set_url '/helpdesk/tickets/new'

      load_validation { has_css?('#new_helpdesk_ticket, form.ticket-form', wait: 10) }

      # Core fields
      element :subject_field,     '#helpdesk_ticket_subject, input[name*="subject"]'
      element :description_field, '.redactor-editor, [contenteditable="true"]'
      element :requester_field,   '#helpdesk_ticket_name, input[placeholder*="Requester"]'
      element :email_field,       '#helpdesk_ticket_email, input[name*="email"]'

      # Dropdowns — Freshservice uses custom JS dropdowns, not native <select>
      element :priority_dropdown, '[data-field="priority"] .dropdown-toggle'
      element :status_dropdown,   '[data-field="status"] .dropdown-toggle'
      element :type_dropdown,     '[data-field="ticket_type"] .dropdown-toggle'
      element :group_dropdown,    '[data-field="group_id"] .dropdown-toggle'

      element :submit_button,     'input[type="submit"], button.create-ticket-btn'
      element :cancel_button,     'a.cancel-btn, button.cancel'

      # ── Form actions ──────────────────────────────────────────────────────

      def fill_subject(text)
        subject_field.set(text)
      end

      def fill_description(text)
        # Freshservice uses a Redactor rich text editor — native .set doesn't work.
        # We must click into the contenteditable div and type.
        description_field.click
        description_field.send_keys(text)
      end

      def fill_requester_email(email)
        # The requester field auto-completes — type and wait for the suggestion,
        # then click it (or set directly if it accepts plain text).
        requester_field.set(email)
        # Wait for and dismiss autocomplete if it appears
        if has_css?('.typeahead .tt-suggestion', wait: 2)
          first('.typeahead .tt-suggestion').click
        end
      end

      def select_priority(label)
        select_from_dropdown('[data-field="priority"] .dropdown-toggle', label)
      end

      def select_status(label)
        select_from_dropdown('[data-field="status"] .dropdown-toggle', label)
      end

      def select_type(label)
        select_from_dropdown('[data-field="ticket_type"] .dropdown-toggle', label)
      end

      # ── High-level composite actions ──────────────────────────────────────

      def fill_and_submit(subject:, description: '', email: '', priority: 'Medium', type: 'Incident')
        fill_subject(subject)
        fill_description(description) unless description.empty?
        fill_requester_email(email) unless email.empty?
        select_priority(priority)
        select_type(type)
        submit_button.click
      end
    end
  end
end
