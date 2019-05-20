# frozen_string_literal: true

module RequiredFieldsHelper
  def required_fields
    return nil if !logged_in?
    return nil if current_user.staff?

    messages = []

    if !current_user.avatar.attached?
      messages << "#{link_to "プロフィール画像を登録してください。", edit_current_user_path, class: "card-list__item-link"}".html_safe
    end

    if !current_user.description?
      messages << "#{link_to "自己紹介を入力してください。", edit_current_user_path, class: "card-list__item-link"}".html_safe
    end

    if !current_user.how_did_you_know?
      messages << "#{link_to "フィヨルドブートキャンプをどこで知ったかを入力してください。", edit_current_user_path, class: "card-list__item-link"}".html_safe
    end

    if !current_user.organization?
      messages << "#{link_to "現在の所属組織を入力してください。", edit_current_user_path, class: "card-list__item-link"}".html_safe
    end

    if current_user.student? && !current_user.github_account?
      messages << "#{link_to "GitHubアカウントを登録してください。", new_card_path, class: "card-list__item-link"}".html_safe
    end

    if current_user.student? && !current_user.slack_account?
      messages << "#{link_to "Slackアカウントを登録してください。", new_card_path, class: "card-list__item-link"}".html_safe
    end

    messages
  end
end
