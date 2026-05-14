# frozen_string_literal: true

class Articles::SummariesController < ApplicationController
  before_action :require_admin_or_mentor_login, only: %i[create]

  def create
    render json: Article.agent_summary(params[:body])
  end
end
