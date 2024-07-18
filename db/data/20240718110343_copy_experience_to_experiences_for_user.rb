# frozen_string_literal: true

class CopyExperienceToExperiencesForUser < ActiveRecord::Migration[6.1]
  def up
    User.find_each do |user|
      case user.experience
      when 'rails'
        user.experiences.set(:rails)
      when 'ruby'
        user.experiences.set(:ruby)
      when 'other_ruby'
        user.experiences.set(:other_ruby_and_javascript)
      when 'html_css'
        user.experiences.set(:html_css)
      end
      user.save!(validate: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
