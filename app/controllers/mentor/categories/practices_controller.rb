# frozen_string_literal: true

class Mentor::Categories::PracticesController < ApplicationController
  before_action :require_admin_or_mentor_login

  def index
    @category = Category.find(params[:category_id])
    @categories_practices = @category
                            .categories_practices
                            .includes(:practice)
                            .order(:position)
  end
end
