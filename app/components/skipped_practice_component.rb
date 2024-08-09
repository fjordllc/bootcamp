# frozen_string_literal: true

class SkippedPracticeComponent < ViewComponent::Base
  def initialize(form:, user:)
    @f = form
    @user = user
  end
end
