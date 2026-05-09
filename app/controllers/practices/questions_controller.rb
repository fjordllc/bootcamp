# frozen_string_literal: true

class Practices::QuestionsController < ApplicationController
  def index
    @practice = Practice.find(params[:practice_id])
    allowed_targets = %w[solved not_solved].freeze
    target = allowed_targets.include?(params[:target]) ? params[:target] : nil
    allowed_scopes = %w[grant_course].freeze
    scope = allowed_scopes.include?(params[:scope]) ? params[:scope] : nil
    practices =
      if scope == 'grant_course'
        @practice
      else
        [@practice, @practice.source_practice].compact
      end
    @questions = Question.where(practice: practices)
                         .includes(%i[correct_answer answers])
                         .by_target(target)
                         .order(created_at: :desc)
                         .page(params[:page])
    @empty_message = empty_message
  end

  private

  def empty_message
    case params[:target]
    when 'solved'
      '解決済みのQ&Aはありません。'
    when 'not_solved'
      '未解決のQ&Aはありません。'
    else
      '質問はありません。'
    end
  end
end
