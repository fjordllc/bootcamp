# frozen_string_literal: true

module RequiredFieldsHelper
  # rubocop:disable Rails/OutputSafety
  def required_fields
    return nil unless logged_in?
    return nil if current_user.staff?

    messages = []

    messages << "#{link_to "プロフィール画像を登録してください。", edit_current_user_path, class: "card-list__item-link"}".html_safe unless current_user.avatar.attached?

    messages << "#{link_to "自己紹介を入力してください。", edit_current_user_path, class: "card-list__item-link"}".html_safe unless current_user.description?

    if current_user.student?
      unless current_user.github_account?
        messages << "#{link_to "GitHubアカウントを登録してください。", edit_current_user_path, class: "card-list__item-link is-github"}".html_safe
      end

      unless current_user.slack_account?
        messages << "#{link_to "Slackアカウントを登録してください。", edit_current_user_path, class: "card-list__item-link is-slack"}".html_safe
      end
    end

    messages
  end
  # rubocop:enable Rails/OutputSafety
end
