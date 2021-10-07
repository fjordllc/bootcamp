# frozen_string_literal: true

class API::MentorController < API::BaseController
  before_action :require_login
  PAGER_NUMBER = 5

  def index
    @worried_users = User.joins('JOIN (SELECT user_id, MAX(published_at) as published_at FROM products GROUP BY user_id) products ON users.id = user_id')
                          .where("published_at <= CURRENT_DATE - interval '2 week'")
                          .order('published_at DESC')
                          .page(params[:page])
                          .per(PAGER_NUMBER)
  end
end
