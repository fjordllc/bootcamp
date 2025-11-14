# frozen_string_literal: true

class Api::MentionUsersController < Api::BaseController
  def index
    users = User.select(:login_name, :name)
                .order(updated_at: :desc)
                .as_json(only: %i[login_name name])
    render json: users
  end
end
