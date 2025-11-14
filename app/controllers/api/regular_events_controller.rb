# frozen_string_literal: true

class Api::RegularEventsController < Api::BaseController
  before_action :require_active_user_login

  def index
    regular_events =
      case params[:target]
      when 'not_finished'
        RegularEvent.not_finished
      else
        RegularEvent.all
      end
    @regular_events = regular_events.with_avatar
                                    .includes(:comments, :users)
                                    .order(created_at: :desc)
                                    .page(params[:page])
  end
end
