# frozen_string_literal: true

module RequiredFieldsHelper
  # rubocop:disable Rails/OutputSafety
  def required_fields
    return nil unless logged_in?
    return nil if current_user.staff?

    messages = []

    required_avatar(messages)
    required_description(messages)

    if current_user.student?
      required_github(messages)
      required_slack(messages)
      required_discord(messages)
    end

    messages
  end

  def required_avatar(messages)
    return if current_user.avatar.attached?

    messages << link_to('プロフィール画像を登録してください。', edit_current_user_path, class: 'card-list__item-link'.to_s.html_safe)
  end

  def required_description(messages)
    return if current_user.description?

    messages << link_to('自己紹介を入力してください。', edit_current_user_path, class: 'card-list__item-link'.to_s.html_safe)
  end

  def required_github(messages)
    return if current_user.github_account?

    messages << link_to('GitHubアカウントを登録してください。', edit_current_user_path, class: 'card-list__item-link is-github'.to_s.html_safe)
  end

  def required_slack(messages)
    return if current_user.slack_account?

    messages << link_to('Slackアカウントを登録してください。', edit_current_user_path, class: 'card-list__item-link is-slack'.to_s.html_safe)
  end

  def required_discord(messages)
    return if current_user.discord_account?

    messages << link_to('Discordアカウントを登録してください。', edit_current_user_path, class: 'card-list__item-link is-discord'.to_s.html_safe)
  end
  # rubocop:enable Rails/OutputSafety
end
