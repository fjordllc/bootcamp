# frozen_string_literal: true

class StaticPagesController < ApplicationController
  skip_before_action :require_active_user_login, raise: false

  layout false, only: :campaign_basic

  def campaign_basic; end
end
