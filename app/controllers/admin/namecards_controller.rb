# frozen_string_literal: true

class Admin::NamecardsController < AdminController
  def create
    arr = []
    params.each do |k, v|
      arr << k if v == "1"
    end
    user_ids = arr.select { |i| i =~ /submission/ }.map { |i| i.gsub(/submission/, "") }
    @users = User.where(id: user_ids)
    render layout: "namecards"
  end
end
