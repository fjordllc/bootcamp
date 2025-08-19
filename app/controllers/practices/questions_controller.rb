# frozen_string_literal: true

class Practices::QuestionsController < ApplicationController
  def index
    @practice = Practice.find(params[:practice_id])
    allowed_targets = %w[solved not_solved].freeze
    target = allowed_targets.include?(params[:target]) ? params[:target] : nil
    @questions = @practice.questions
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
