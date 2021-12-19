# frozen_string_literal: true

class API::Admin::CountController < API::Admin::BaseController
  def show
    users_count = User.where(
      admin: false,
      mentor: false,
      adviser: false,
      retired_on: nil,
      graduated_on: nil
    ).count

    render json: { users_count: users_count }
  end
end
