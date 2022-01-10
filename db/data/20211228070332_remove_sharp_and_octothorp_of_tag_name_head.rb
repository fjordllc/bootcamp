# frozen_string_literal: true

class RemoveSharpAndOctothorpOfTagNameHead < ActiveRecord::Migration[6.1]
  BEGINNING_WITH_SHARP_OR_OCTOTHORP = '^(#|＃|♯)( |　)*.*'

  def up
    ActsAsTaggableOn::Tag.where('name ~* ?', BEGINNING_WITH_SHARP_OR_OCTOTHORP).find_each do |tag_with_symbol_name_head|
      head_removed_name = tag_with_symbol_name_head.name.sub(/^(#|＃|♯)( |　)*/, '')
      existing_tag_id = ActsAsTaggableOn::Tag.where(name: head_removed_name).pick(:id)
      if existing_tag_id
        resolve_tag_name_duplication(
          ActsAsTaggableOn::Tagging.where(tag_id: tag_with_symbol_name_head.id),
          existing_tag_id,
          tag_with_symbol_name_head
        )
      else
        tag_with_symbol_name_head.name = head_removed_name
        tag_with_symbol_name_head.save!(validate: false)
      end
    end
  end

  def resolve_tag_name_duplication(taggings_of_symbol_name_head_tag, existing_tag_id, tag_with_symbol_name_head)
    ActsAsTaggableOn::Tag.transaction do
      ActsAsTaggableOn::Tagging.transaction do
        taggings_of_symbol_name_head_tag.find_each do |tagging_of_symbol_name_head_tag|
          if tagging_of_existing_tag_with_the_same_taggable_exists?(existing_tag_id, tagging_of_symbol_name_head_tag)
            tagging_of_symbol_name_head_tag.destroy!
          else
            tagging_of_symbol_name_head_tag.tag_id = existing_tag_id
            tagging_of_symbol_name_head_tag.save!(validate: false)
          end
        end
        tag_with_symbol_name_head.destroy!
      end
    end
  end

  def tagging_of_existing_tag_with_the_same_taggable_exists?(existing_tag_id, tagging_of_symbol_name_head_tag)
    ActsAsTaggableOn::Tagging.where(
      tag_id: existing_tag_id,
      taggable_id: tagging_of_symbol_name_head_tag.taggable_id
    ).exists?
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
