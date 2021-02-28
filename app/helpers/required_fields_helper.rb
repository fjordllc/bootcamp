# frozen_string_literal: true

module RequiredFieldsHelper
  # rubocop:disable Rails/OutputSafety
  def required_fields
    return nil unless logged_in?
    return nil if current_user.staff?

    messages = []

    messages << link_to('プロフィール画像を登録してください。', edit_current_user_path, class: 'card-list__item-link'.to_s.html_safe) unless current_user.avatar.attached?

    messages << link_to('自己紹介を入力してください。', edit_current_user_path, class: 'card-list__item-link'.to_s.html_safe) unless current_user.description?

    required_sns(messages) if current_user.student?

    messages
  end

  def required_sns(messages)
    return if current_user.github_account?

    messages << link_to('GitHubアカウントを登録してください。', edit_current_user_path, class: 'card-list__item-link is-github'.to_s.html_safe)

    return if current_user.slack_account?

    messages << link_to('Slackアカウントを登録してください。', edit_current_user_path, class: 'card-list__item-link is-slack'.to_s.html_safe)

    return if current_user.discord_account?

    messages << link_to('Discordアカウントを登録してください。', edit_current_user_path, class: 'card-list__item-link is-discord'.to_s.html_safe)
  end
  # rubocop:enable Rails/OutputSafety
end
