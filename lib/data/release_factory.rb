# frozen_string_literal: true

module ReleaseFactory
  # release_type: 1=Minor, 2=Standard, 3=Major, 4=Emergency
  # status:       1=Open, 2=On hold, 3=In progress, 4=Incomplete, 5=Completed

  def self.build(overrides = {})
    now = Time.now
    {
      subject:              Faker::Lorem.sentence(word_count: 4),
      description:          Faker::Lorem.paragraph(sentence_count: 2),
      release_type:         2,   # Standard
      status:               1,   # Open
      planned_start_date:   (now + (3600 * 24)).strftime('%Y-%m-%dT%H:%M:%SZ'),
      planned_end_date:     (now + (3600 * 72)).strftime('%Y-%m-%dT%H:%M:%SZ')
    }.merge(overrides)
  end
end
