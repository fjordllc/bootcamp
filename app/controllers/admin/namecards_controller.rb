# frozen_string_literal: true

class Admin::NamecardsController < AdminController
  layout "namecards"

  def index
    user_ids = params.select { |k, v| k =~ /submission/ && v == "1" }.keys.map { |i| i.gsub(/submission/, "") }
    @users = User.where(id: user_ids)
  end
end
