# frozen_string_literal: true

class API::GrassesController < API::BaseController
  def show
    id, end_date_str = params.values_at(:id, :end_date)
    end_date = end_date_str ? Date.parse(end_date_str) : Date.current
    user = User.find(id)
    @times = Grass.times(user, end_date)
  end
end
