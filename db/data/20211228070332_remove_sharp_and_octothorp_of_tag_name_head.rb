# frozen_string_literal: true

class RemoveSharpAndOctothorpOfTagNameHead < ActiveRecord::Migration[6.1]
  BEGINNING_WITH_SHARP_OR_OCTOTHORP = '^(#|＃|♯)( |　)*.*'

  def up
    ActsAsTaggableOn::Tag.where('name ~* ?', BEGINNING_WITH_SHARP_OR_OCTOTHORP).find_each do |tag|
      tag.name.sub!(/^(#|＃|♯)( |　)*/, '')
      tag.save!(validate: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
