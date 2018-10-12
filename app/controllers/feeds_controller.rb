# frozen_string_literal: true

class FeedsController < ApplicationController
  def index
    @users = User.student.where.not(blog_url: nil)
  end
end
