# frozen_string_literal: true

class Practices::CompletionController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  layout 'completion'

  def show
    @practice = Practice.find(params[:practice_id])
  end
end
