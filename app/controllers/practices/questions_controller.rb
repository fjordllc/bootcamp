# frozen_string_literal: true

class Practices::QuestionsController < ApplicationController
  before_action :require_login

  def index
    @practice = Practice.find(params[:practice_id])
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
