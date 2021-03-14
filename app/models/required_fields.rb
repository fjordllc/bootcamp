# frozen_string_literal: true

class RequiredFields
  # rubocop:disable Rails/OutputSafety
  class << self
    def create_register_messages(current_user)
      return nil if current_user.staff?

      messages = []

      messages << required_avatar(current_user)
      messages << required_description(current_user)

      if current_user.student?
        messages << required_github(current_user)
        messages << required_slack(current_user)
        messages << required_discord(current_user)
      end

      messages.compact
    end

    private

    def required_avatar(current_user)
      return if current_user.avatar.attached?

      ActionController::Base.helpers.link_to('プロフィール画像を登録してください。', edit_current_user_path, class: 'card-list__item-link'.to_s.html_safe)
    end

    def required_description(current_user)
      return if current_user.description?

      ActionController::Base.helpers.link_to('自己紹介を入力してください。', edit_current_user_path, class: 'card-list__item-link'.to_s.html_safe)
    end

    def required_github(current_user)
      return if current_user.github_account?

      ActionController::Base.helpers.link_to('GitHubアカウントを登録してください。', edit_current_user_path, class: 'card-list__item-link is-github'.to_s.html_safe)
    end

    def required_slack(current_user)
      return if current_user.slack_account?

      ActionController::Base.helpers.link_to('Slackアカウントを登録してください。', edit_current_user_path, class: 'card-list__item-link is-slack'.to_s.html_safe)
    end

    def required_discord(current_user)
      return if current_user.discord_account?

      ActionController::Base.helpers.link_to('Discordアカウントを登録してください。', edit_current_user_path, class: 'card-list__item-link is-discord'.to_s.html_safe)
    end

    def edit_current_user_path
      Rails.application.routes.url_helpers.edit_current_user_path
    end
  end
  # rubocop:enable Rails/OutputSafety
end
