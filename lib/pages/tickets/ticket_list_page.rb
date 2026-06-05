# frozen_string_literal: true

# lib/pages/tickets/ticket_list_page.rb

module Pages
  module Tickets
    class TicketListPage < BasePage
      set_url '/helpdesk/tickets'

      load_validation { has_css?('.tickets-list, #helpdesk-tickets', wait: 10) }

      element :new_ticket_button, 'a[href*="new"], button.new-ticket-btn'
      element :search_box,        '#search-tickets, input[placeholder*="Search"]'
      elements :ticket_rows,      'tr.ticket-item, .ticket-row'

      # Click the "New Ticket" button and return the form page.
      def open_new_form
        new_ticket_button.click
        TicketFormPage.new
      end

      # Find a ticket row by subject text.
      def ticket_with_subject(subject)
        ticket_rows.find { |row| row.text.include?(subject) }
      end

      def has_ticket_with_subject?(subject)
        ticket_rows.any? { |row| row.text.include?(subject) }
      end
    end
  end
end
