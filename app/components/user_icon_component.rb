# frozen_string_literal: true

class UserIconComponent < ViewComponent::Base
  def initialize(user:)
    @user = user
  end
end
