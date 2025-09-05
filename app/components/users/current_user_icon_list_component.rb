# frozen_string_literal: true

class Users::CurrentUserIconListComponent < ViewComponent::Base
  include TimeRangeHelper
  def initialize(users:)
    @users = users
  end
end
