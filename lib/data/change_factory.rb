# frozen_string_literal: true

module ChangeFactory
  # change_type:  1=Minor, 2=Standard, 3=Major, 4=Emergency
  # risk:         1=Low, 2=Medium, 3=High, 4=Very High
  # priority:     1=Low, 2=Medium, 3=High, 4=Urgent
  # status:       1=Open, 2=Planning, 3=Awaiting Approval …

  def self.build(overrides = {})
    now = Time.now
    {
      subject:              Faker::Lorem.sentence(word_count: 4),
      description:          Faker::Lorem.paragraph(sentence_count: 2),
      change_type:          2,   # Standard
      risk:                 1,   # Low
      priority:             2,   # Medium
      status:               1,   # Open
      planned_start_date:   (now + (3600 * 24)).strftime('%Y-%m-%dT%H:%M:%SZ'),
      planned_end_date:     (now + (3600 * 48)).strftime('%Y-%m-%dT%H:%M:%SZ')
    }.merge(overrides)
  end

  def self.build_emergency(overrides = {})
    build({ change_type: 4, risk: 4, priority: 4 }.merge(overrides))
  end
end
