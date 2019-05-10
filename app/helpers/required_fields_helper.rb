# frozen_string_literal: true

module RequiredFieldsHelper
  def required_fields
    return nil if !logged_in?
    return nil if current_user.staff?

    messages = []

    if current_user.student? && !current_user.free? && !current_user.paid?
      messages << "クレジットカードを#{link_to "登録", new_card_path}してください。".html_safe
    end

    if !current_user.avatar.attached?
      messages << "プロフィール画像を#{link_to "登録", edit_current_user_path}してください。".html_safe
    end

    if !current_user.description?
      messages << "自己紹介を#{link_to "入力", edit_current_user_path}してください。".html_safe
    end

    if !current_user.how_did_you_know?
      messages << "弊社をどこで知ったかを#{link_to "入力", edit_current_user_path}してください。".html_safe
    end

    if !current_user.organization?
      messages << "現在の所属組織を#{link_to "入力", edit_current_user_path}してください。".html_safe
    end

    messages
  end
end
