# frozen_string_literal: true

class Practices::PagesController < ApplicationController
  def index
    @practice = Practice.find(params[:practice_id])
  end
end
