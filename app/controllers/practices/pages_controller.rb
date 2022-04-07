# frozen_string_literal: true

class Practices::PagesController < ApplicationController
  before_action :require_login

  def index
    @practice = Practice.find(params[:practice_id])
  end
end
