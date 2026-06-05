# frozen_string_literal: true

# lib/data/ticket_factory.rb
# ─────────────────────────────────────────────────────────────────────────────
# Builds Ticket payload hashes for API and UI tests.
#
# WHY a factory module instead of hard-coded hashes in specs?
# 1. Faker generates unique data — prevents cross-test collisions.
# 2. Callers can override any field with keyword args.
# 3. Central place to keep up with Freshservice's required field changes.
#
# INTERVIEW: why NOT use FactoryBot here?
# FactoryBot is designed for ORM objects (ActiveRecord). We have plain hashes.
# Building our own lightweight factory is simpler and has zero transitive deps.
# ─────────────────────────────────────────────────────────────────────────────

require 'faker'

module TicketFactory
  # Ticket priority: 1=Low, 2=Medium, 3=High, 4=Urgent
  # Ticket status:  1=Open, 2=Pending, 3=Resolved, 4=Closed
  # Ticket type:    Incident / Service Request (as string)

  def self.build(overrides = {})
    {
      subject:     Faker::Lorem.sentence(word_count: 5),
      description: Faker::Lorem.paragraph(sentence_count: 3),
      email:       Faker::Internet.email,
      priority:    2,         # Medium — safe default for test accounts
      status:      1,         # Open
      type:        'Incident'
    }.merge(overrides)
  end

  def self.build_urgent(overrides = {})
    build({ priority: 4, type: 'Incident' }.merge(overrides))
  end

  def self.build_service_request(overrides = {})
    build({ type: 'Service Request', priority: 1 }.merge(overrides))
  end

  # Invalid payloads for negative testing
  def self.build_without_subject
    build.except(:subject)
  end

  def self.build_without_email
    build.except(:email)
  end
end
