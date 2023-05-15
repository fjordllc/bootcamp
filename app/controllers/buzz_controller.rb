# frozen_string_literal: true

class BuzzController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[show]

  def show
    render layout: 'welcome'
  end

  def edit
  end

  def update
  end
end
