# frozen_string_literal: true

module ArticlesHelper
  def contributor
    User.admins.or(User.mentor).pluck(:login_name, :id).sort
  end
end
