# frozen_string_literal: true

class UserIconListComponent < ViewComponent::Base
  def initialize(users:)
    @users = users
  end
end
