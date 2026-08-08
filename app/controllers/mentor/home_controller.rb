# frozen_string_literal: true

class Mentor::HomeController < MentorController
  def index
    @worried_users = DelayedUsersQuery.new.call.order(completed_at: :asc)
  end
end
