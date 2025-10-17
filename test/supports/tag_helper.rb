# frozen_string_literal: true

module TagHelper
  def fill_in_tag(name, selector = '.tagify__input')
    tag_count_before = all('.tagify__tag').count
    tag_input = find(selector)
    tag_input.set name
    tag_input.native.send_keys :return
    assert_selector('.tagify__tag', count: tag_count_before + 1, wait: 5)
  end

  def fill_in_tag_with_alert(name, selector = '.tagify__input')
    tag_input = find(selector)
    tag_input.set name
    accept_alert do
      tag_input.native.send_keys :return
    end
    assert_selector(selector)
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
