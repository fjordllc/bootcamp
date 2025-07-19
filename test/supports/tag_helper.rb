# frozen_string_literal: true

module TagHelper
  def fill_in_tag(name, selector = '.tagify__input')
    tag_input = find(selector)
    sleep 1
    tag_input.set name
    tag_input.native.send_keys :return
    assert_selector('.tagify__tag', text: name, wait: 2)
  end

  def fill_in_tag_with_alert(name, selector = '.tagify__input')
    tag_input = find(selector)
    sleep 1
    tag_input.set name
    accept_alert do
      tag_input.native.send_keys :return
    end
  end

  def find_tags(taggable_name)
    sql = <<~SQL
      SELECT
        DISTINCT tags.name AS name
      FROM
        tags
        JOIN taggings ON tags.id = taggings.tag_id
      WHERE
        taggings.taggable_type = :taggable_name
    SQL
    ActsAsTaggableOn::Tag.find_by_sql([sql, { taggable_name: }]).pluck(:name).sort
  end
end
