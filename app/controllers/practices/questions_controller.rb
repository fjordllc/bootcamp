# frozen_string_literal: true

class Practices::QuestionsController < ApplicationController
  def index
    @practice = Practice.find(params[:practice_id])
    @empty_message = empty_message
    
    # Use same logic as API controller for consistency
    questions = case params[:target]
               when 'solved'
                 Question.solved
               when 'not_solved'
                 Question.not_solved.not_wip
               else
                 Question.all
               end
    questions = questions.where(practice_id: params[:practice_id])
    
    @questions = questions
                 .with_avatar
                 .includes(:practice, :answers, :tags, :correct_answer)
                 .order(updated_at: :desc, id: :desc)
                 .page(params[:page])
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
