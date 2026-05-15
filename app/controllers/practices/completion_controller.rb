# frozen_string_literal: true

class Practices::CompletionController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  layout 'not_logged_in'

  def show
    @practice = Practice.find(params[:practice_id])
  end
end
