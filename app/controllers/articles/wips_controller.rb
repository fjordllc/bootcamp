# frozen_string_literal: true

class Articles::WipsController < ApplicationController
  def index
    @articles = Article.where(wip: true)
    render layout: 'welcome'
  end
end
