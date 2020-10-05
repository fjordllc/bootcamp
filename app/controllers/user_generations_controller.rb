# frozen_string_literal: true

class UserGenerationsController < ApplicationController
  before_action :require_login

  def show
    @generation = params[:id]
  end
end
