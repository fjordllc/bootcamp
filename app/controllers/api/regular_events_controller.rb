# frozen_string_literal: true

class API::RegularEventsController < API::BaseController
  before_action :require_login

  def index
    @regular_events = RegularEvent.with_avatar
                                  .includes(:comments, :users)
                                  .order(created_at: :desc)
                                  .page(params[:page])
  end
end
