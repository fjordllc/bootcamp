# frozen_string_literal: true

class AddSlugToPages < ActiveRecord::Migration[6.1]
  SLUG_BY_ID = {
    240 => 'how_to_ask_questions',
    245 => 'use_the_question_room',
    287 => 'suspension_of_membership',
    303 => 'follow_the_report'
  }.freeze

  def up
    SLUG_BY_ID.each do |id, slug|
      page = Page.find(id)
      next unless page

      page.update_column(:slug, slug) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
