# frozen_string_literal: true

class WelcomeController < ApplicationController
  layout "welcome"

  def index
  end

  def pricing
    @days = [
      Date.current.strftime('%m/%d'),
      Date.current.since(1.day).strftime('%m/%d'),
      Date.current.since(2.day).strftime('%m/%d'),
      Date.current.since(3.day).since(1.month).strftime('%m/%d'),
    ]
  end

  def faq
  end

  def practices
    @categories = Course.first.categories.preload(:practices).order(:position)
  end

  def coc
  end
end
