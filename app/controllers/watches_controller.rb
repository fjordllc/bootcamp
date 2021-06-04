# frozen_string_literal: true

class WatchesController < ApplicationController
  before_action :require_login

  PAGINATES_PER = 25
  def index; end
end
