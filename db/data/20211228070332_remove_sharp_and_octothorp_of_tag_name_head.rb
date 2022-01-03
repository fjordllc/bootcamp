# frozen_string_literal: true

class RemoveSharpAndOctothorpOfTagNameHead < ActiveRecord::Migration[6.1]
  BEGINNING_WITH_SHARP_OR_OCTOTHORP = '^(#|＃|♯)( |　)*.*'

  def up
    ActsAsTaggableOn::Tag.where('name ~* ?', BEGINNING_WITH_SHARP_OR_OCTOTHORP).find_each do |tag|
      head_removed_name = tag.name.sub(/^(#|＃|♯)( |　)*/, '')
      if ActsAsTaggableOn::Tag.exists?(name: head_removed_name)
        tag_id = ActsAsTaggableOn::Tag.find_by(name: head_removed_name).id
        ActsAsTaggableOn::Tagging.where(tag_id: tag.id).find_each do |tagging_to_replace|
          tagging_to_replace.tag_id = tag_id
          tagging_to_replace.save!(validate: false)
        end
      else
        tag.name = head_removed_name
        tag.save!(validate: false)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
