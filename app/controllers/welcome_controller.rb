# frozen_string_literal: true

class WelcomeController < ApplicationController
  layout "welcome"

  def index
  end

  def pricing
  end

  def faq
  end

  def practices
    @categories = Course.first.categories.preload(:practices).order(:position)
  end

  def tos
  end

  def law
  end

  def coc
  end
end
