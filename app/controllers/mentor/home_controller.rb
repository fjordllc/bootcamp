# frozen_string_literal: true

class Mentor::HomeController < MentorController
  def index
    @worried_users = User.delayed.order(completed_at: :asc)
  end
end
