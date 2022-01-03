# frozen_string_literal: true

class RemoveSharpAndOctothorpOfTagNameHead < ActiveRecord::Migration[6.1]
  BEGINNING_WITH_SHARP_OR_OCTOTHORP = '^(#|＃|♯)( |　)*.*'

  def up
    ActsAsTaggableOn::Tag.where('name ~* ?', BEGINNING_WITH_SHARP_OR_OCTOTHORP).find_each do |tag_to_remove_name_head|
      head_removed_name = tag_to_remove_name_head.name.sub(/^(#|＃|♯)( |　)*/, '')
      if ActsAsTaggableOn::Tag.exists?(name: head_removed_name)
        existing_tag_id = ActsAsTaggableOn::Tag.find_by(name: head_removed_name).id
        ActsAsTaggableOn::Tagging.where(tag_id: tag_to_remove_name_head.id).find_each do |tagging_to_be_replaced|
          tagging_to_be_replaced.tag_id = existing_tag_id
          tagging_to_be_replaced.save!(validate: false)
        end
        tag_to_remove_name_head.destroy
      else
        tag_to_remove_name_head.name = head_removed_name
        tag_to_remove_name_head.save!(validate: false)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
