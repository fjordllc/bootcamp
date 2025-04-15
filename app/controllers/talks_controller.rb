# frozen_string_literal: true

class TalksController < ApplicationController
  before_action :require_admin_login, only: %i[index]
  before_action :set_talk, only: %i[show]
  before_action :set_user, only: %i[show]
  before_action :set_members, only: %i[show]
  before_action :allow_show_talk_page_only_admin, only: %i[show]

  ALLOWED_TARGETS = %w[all student_and_trainee mentor graduate adviser trainee retired].freeze

  def index
    @target = params[:target]
    @talks = Talk.joins(:user)
                 .includes(user: [{ avatar_attachment: :blob }, :discord_profile])
                 .order(updated_at: :desc, id: :asc)
    users = User.users_role(@target, allowed_targets: ALLOWED_TARGETS, default_target: 'all')

    if params[:search_word]
      search_user = SearchUser.new(word: params[:search_word], users:, target: @target, require_retire_user: true)
      @validated_search_word = search_user.validate_search_word
    end

    if @validated_search_word
      searched_users = search_user.search
      @searched_talks = @talks.merge(searched_users).page(params[:page])
    else
      @talks = @talks.merge(users).page(params[:page])
    end
  end

  def show
    @comments = @talk.comments.order(:created_at)
  end

  private

  def allow_show_talk_page_only_admin
    return if current_user.admin? || @talk.user == current_user

    redirect_to talk_path(current_user.talk)
  end

  def set_talk
    @talk = Talk.find(params[:id])
  end

  def set_user
    @user = current_user.admin? ? @talk.user : current_user
  end

  def set_members
    @members = User.with_attached_avatar
                   .where(id: User.admins.ids.push(@talk.user_id))
                   .order(:id)
  end
end
