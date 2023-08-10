# frozen_string_literal: true

class AddCurrentTimeToPublishedAtForPublishedRegularEvent < ActiveRecord::Migration[6.1]
  def up
    RegularEvent.find_each do |regular_event|
      unless regular_event.wip
        regular_event.published_at = Time.current
        regular_event.save!(validate: false)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
