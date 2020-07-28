# frozen_string_literal: true

class GraduationWorksController < ApplicationController
  layout "welcome"

  def index
    @graduation_works = Work.graduation_works.order(created_at: :desc).page(params[:page])
  end

  def show
    @graduation_work = Work.graduation_works.find(params[:id])
  end
end
