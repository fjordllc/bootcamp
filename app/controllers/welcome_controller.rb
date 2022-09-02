# frozen_string_literal: true

class WelcomeController < ApplicationController
  layout 'welcome'

  def index
    @mentors = User.with_attached_profile_image.where(mentor: true).includes(related_books: { cover_attachment: :blob })
  end

  def pricing; end

  def faq; end

  def training; end

  def practices
    @categories = Course.first.categories.preload(:practices).order(:position)
  end

  def tos; end

  def pp; end

  def law; end

  def coc; end
end
