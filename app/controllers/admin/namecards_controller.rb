# frozen_string_literal: true

class Admin::NamecardsController < AdminController
  def new
    @target = params[:target] || "except_retired"
    @users = User.users_role(@target)
  end

  def create
    arr = []
    params.each do |k, v|
      arr << k if v == "1"
    end
    user_ids = arr.select { |i| i =~ /submission/ }.map { |i| i.gsub(/submission/, "") }
    @users = User.where(id: user_ids)
  end
end
