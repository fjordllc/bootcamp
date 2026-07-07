# frozen_string_literal: true

class Practices::QuestionsController < ApplicationController
  def index
    @practice = Practice.find(params[:practice_id])
    @questions = Question.where(practice: question_practices)
                         .includes(%i[correct_answer answers])
                         .by_target(selected_target)
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

  def question_practices
    if selected_scope == 'grant_course'
      [@practice]
    else
      [@practice, @practice.source_practice].compact
    end
  end

  def selected_target
    params[:target] if %w[solved not_solved].include?(params[:target])
  end

  def selected_scope
    params[:scope] if %w[grant_course].include?(params[:scope])
  end
end
