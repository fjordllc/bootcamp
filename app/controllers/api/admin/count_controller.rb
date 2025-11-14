# frozen_string_literal: true

class Api::Admin::CountController < Api::Admin::BaseController
  def show
    users_count = User.where(
      admin: false,
      mentor: false,
      adviser: false,
      retired_on: nil,
      training_completed_at: nil,
      graduated_on: nil,
      hibernated_at: nil
    ).count

    render json: { users_count: }
  end
end
