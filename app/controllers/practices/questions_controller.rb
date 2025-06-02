# frozen_string_literal: true

class Practices::QuestionsController < ApplicationController
  def index
    @practice = Practice.find(params[:practice_id])
    @empty_message = empty_message
    @questions = Question
                 .by_target(params[:target])
                 .where(practice_id: params[:practice_id])
                 .with_avatar
                 .includes(:practice, :answers, :tags, :correct_answer, user: { avatar_attachment: :blob })
                 .latest_update_order
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
