# frozen_string_literal: true

class ReverseShowMentorProfileForUsers < ActiveRecord::Migration[6.1]
  def up
    # rubocop:disable Rails/SkipsModelValidations
    User.update_all('show_mentor_profile = NOT show_mentor_profile')
  end

  def down
    User.update_all('show_mentor_profile = NOT show_mentor_profile')
    # rubocop:enable Rails/SkipsModelValidations
  end
end
