# frozen_string_literal: true

class CategoriesController < ApplicationController
  before_action :require_login

  def show
    @category = Category.find(params[:id])
  end
end
