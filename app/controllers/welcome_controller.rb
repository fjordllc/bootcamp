# frozen_string_literal: true

class WelcomeController < ApplicationController
  layout "welcome"

  def index
  end

  def pricing
    @days = [
      Time.current.strftime("%m/%d %H:%M:%S"),
      Time.current.since(1.day).strftime("%m/%d"),
      Time.current.since(2.day).strftime("%m/%d %H:%M:%S"),
      Time.current.since(2.day).since(1.second).strftime("%m/%d %H:%M:%S"),
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
