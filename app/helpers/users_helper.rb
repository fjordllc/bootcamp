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

  def user_submit_label(user, from)
    if from == :new
      if user.adviser?
        "アドバイザー登録"
      else
        "参加する"
      end
    else
      "更新する"
    end
  end

  def user_github_grass_url(user)
    "https://grass-graph.moshimo.works/images/#{user.github_account}.png?background=none"
  end
end
