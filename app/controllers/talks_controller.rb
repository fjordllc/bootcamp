# frozen_string_literal: true

class TalksController < ApplicationController
  before_action :require_admin_login, only: %i[index]
  before_action :set_talk, only: %i[show comments]
  before_action :set_user, only: %i[show comments]
  before_action :set_members, only: %i[show]
  before_action :allow_show_talk_page_only_admin, only: %i[show comments]

  ALLOWED_TARGETS = %w[all student_and_trainee mentor graduate adviser trainee retired].freeze
  COMMENT_LIMIT = 8

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
    @comment_total_count = @talk.comments.count
    @comments = comments_with_users.order(created_at: :desc, id: :desc).limit(COMMENT_LIMIT).to_a.reverse
    @reports = @user.reports.list.limit(20)
  end

  def comments
    return head :bad_request unless params[:target] || params[:before]

    if params[:target]
      @comments = [comments_with_users.find(params[:target])]
      comment_remaining = 0
    else
      before = @talk.comments.find(params[:before])
      @comments = comments_before(before)
                  .order(created_at: :desc, id: :desc)
                  .limit(COMMENT_LIMIT)
                  .to_a
                  .reverse
      comment_remaining = @comments.empty? ? 0 : comments_before(@comments.first).count
    end
    response.set_header('X-Comment-Remaining', comment_remaining.to_s)
    render partial: 'comments/comment', collection: @comments, as: :comment,
           locals: { user: current_user, latest_comment: nil }
  end

  private

  def allow_show_talk_page_only_admin
    return if current_user.admin? || @talk.user == current_user

    if action_name == 'comments'
      head :forbidden
    else
      redirect_to talk_path(current_user.talk)
    end
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

  def comments_with_users
    @talk.comments.includes(user: [{ avatar_attachment: :blob }, { company: { logo_attachment: :blob } }])
  end

  def comments_before(comment)
    comments_with_users.where(
      'created_at < ? OR (created_at = ? AND id < ?)',
      comment.created_at,
      comment.created_at,
      comment.id
    )
  end
end
