# frozen_string_literal: true

class Practices::PagesController < ApplicationController
  before_action :require_login

  def index
    @practice = Practice.find(params[:practice_id])
    @pages = @practice.pages.with_avatar
                .includes(:comments,
                { last_updated_user: { avatar_attachment: :blob } })
                .order(updated_at: :desc)
                .page(params[:page])
  end
end
