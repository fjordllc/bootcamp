# frozen_string_literal: true

SLUG_BY_ID = {
  240 => 'how_to_ask_questions',
  245 => 'use_the_question_room',
  287 => 'suspension_of_membership',
  303 => 'follow_the_report'
}.freeze

namespace :add_slug_to_pages do
  desc 'Add slug to a specific pages.'
  task add_slug_to_pages: :environment do
    SLUG_BY_ID.each do |id, slug|
      page = Page.find(id)
      next unless page

      page.update_column(:slug, slug)
    end
  end
end
