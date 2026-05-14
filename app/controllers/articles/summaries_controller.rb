# frozen_string_literal: true

class Articles::SummariesController < ApplicationController
  def create
    render json: Article.agent_summary(params[:body])
  end
end
