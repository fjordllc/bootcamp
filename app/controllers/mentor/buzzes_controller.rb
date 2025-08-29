# frozen_string_literal: true

class Mentor::BuzzesController < ApplicationController
  PER_PAGE = 50

  def index
    @buzzes = Buzz.all.page(params[:page]).per(PER_PAGE)
  end

  def new; end

  def edit; end

  def create; end

  def update; end

  def destroy; end
end
