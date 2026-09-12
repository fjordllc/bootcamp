# frozen_string_literal: true

class PracticeText
  def initialize(practice)
    @practice = practice
  end

  def all_text
    [@practice.title, @practice.description, @practice.goal].join("\n")
  end
end
