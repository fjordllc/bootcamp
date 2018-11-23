# frozen_string_literal: true

module UsersHelper
  def user_tab_attrs(name)
    target = params.fetch("target", "all")
    if target == name
      "active"
    else
      ""
    end
  end

  def user_tr_attrs(user)
    if user.active?
      { class: "active" }
    else
      { class: "inactive" }
    end
  end

  def user_github_url(user)
    "https://github.com/#{user.github_account}"
  end
end
