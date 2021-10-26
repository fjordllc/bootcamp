# frozen_string_literal: true

class API::GrassesController < API::BaseController
  def show
    user = User.find(params[:id])
    date = params[:end_date] ? Date.parse(params[:end_date]) : Date.current
    @times = Grass.times(user, date)
  end
end
