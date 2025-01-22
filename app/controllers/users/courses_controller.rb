# frozen_string_literal: true

class Users::CoursesController < ApplicationController
  ALLOWED_TARGETS = %w[rails_course front_end_course other_courses].freeze

  PAGER_NUMBER = 24

  def index
    @target = ALLOWED_TARGETS.include?(params[:target]) ? params[:target] : ALLOWED_TARGETS.first
    course_names =
      if @target == 'other_courses'
        Course.where(published: false).pluck(:title)
      else
        Course.where(published: true).where(title: I18n.t("course_names.#{@target}")).pluck(:title)
      end

    target_users = User.by_course(course_names).students_and_trainees
    @users = target_users
             .page(params[:page]).per(PAGER_NUMBER)
             .preload(:avatar_attachment, :course, :taggings)
             .order(updated_at: :desc)

    return unless params[:search_word]

    search_user = SearchUser.new(word: params[:search_word], users: @users, target: @target)
    @users = search_user.search
  end
end
