# frozen_string_literal: true

class FeedsController < ApplicationController
  def index
    @users = User.students.where.not(blog_url: nil)
  end
end
