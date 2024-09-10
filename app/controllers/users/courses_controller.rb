# frozen_string_literal: true

class Users::CoursesController < ApplicationController
  ALLOWED_TARGETS = %w[rails_course front_end_course other_courses].freeze

  def index
    @target = ALLOWED_TARGETS.include?(params[:target]) ? params[:target] : ALLOWED_TARGETS.first
  end
end
