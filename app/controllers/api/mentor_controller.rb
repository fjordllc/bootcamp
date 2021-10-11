# frozen_string_literal: true

class API::MentorController < API::BaseController
  before_action :require_login

  def index
    @worried_users = User.joins(:products)
                         .select('users.*', :published_at)
                         .where('published_at <= ?', 2.weeks.ago.to_date)
                         .order(published_at: :desc)
  end
end
