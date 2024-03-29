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
    params[:search_word] = validate_search_word(params[:search_word]) if params[:search_word]

    if params[:search_word]
      # search_by_keywords内では { unretired } というスコープが設定されている
      # 退会したユーザーも検索対象に含めたいので、unscope(where: :retired_on) で上記のスコープを削除
      searched_users = users.search_by_keywords(word: params[:search_word]).unscope(where: :retired_on)
      # もし検索対象が退会したユーザーである場合、searched_usersには退会していないユーザーも含まれているため、retired スコープを設定する
      searched_users = searched_users.retired if @target == 'retired'
      @searched_talks = @talks.merge(searched_users).page(params[:page])
    else
      @talks = @talks.merge(users).page(params[:page])
    end
  end

  def show; end

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

  def validate_search_word(search_word)
    if search_word.match?(/^[\w-]+$/)
      search_word.strip if search_word.strip.length >= 3
    elsif search_word.strip.length >= 2
      search_word.strip
    end
  end
end
