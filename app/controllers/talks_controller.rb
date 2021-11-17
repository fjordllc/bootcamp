# frozen_string_literal: true

class TalksController < ApplicationController
  before_action :require_admin_login

  def index; end
end
