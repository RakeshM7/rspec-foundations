# frozen_string_literal: true

module ProblemFactory
  # Problem status: 1=Open, 2=Change Requested, 3=Change Made, 4=Closed
  # Problem priority: 1=Low, 2=Medium, 3=High, 4=Urgent

  def self.build(overrides = {})
    {
      subject:      Faker::Lorem.sentence(word_count: 4),
      description:  Faker::Lorem.paragraph(sentence_count: 2),
      due_by:       (Date.today + 7).strftime('%Y-%m-%dT%H:%M:%SZ'),
      priority:     2,
      status:       1,
      agent_id:     nil,   # set from ENV or test setup if needed
      group_id:     nil
    }.merge(overrides).compact
  end
end
