# frozen_string_literal: true

class Users::CoursesController < ApplicationController
  ALLOWED_TARGETS = %w[rails_course front_end_course other_courses].freeze

  def index
    @target = ALLOWED_TARGETS.include?(params[:target]) ? params[:target] : ALLOWED_TARGETS.first
    course_names = { rails_course: 'Railsエンジニア',
                     front_end_course: 'フロントエンドエンジニア',
                     other_courses: %w[Unityゲームエンジニア iOSエンジニア] }
    @users = User.by_course(course_names[@target.to_sym]).students_and_trainees
  end
end
