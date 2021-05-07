# frozen_string_literal: true

class API::MentionUsersController < API::BaseController
  def index
    users = User.select(:login_name, :name)
                .order(updated_at: :desc)
                .as_json(except: :id)
    render json: users
  end
end
