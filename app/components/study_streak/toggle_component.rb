# frozen_string_literal: true

class StudyStreak::ToggleComponent < ViewComponent::Base
  def initialize(target_user:)
    @target_user = target_user
  end

  private

  attr_reader :target_user

  def redirect_path
    helpers.request.fullpath
  end
end
