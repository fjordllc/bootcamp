# frozen_string_literal: true

class BuzzController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[show]
  before_action :require_admin_or_mentor_login, except: %i[show]

  def show
    render layout: 'welcome'
  end

  def edit
  end

  def update
  end
end
