# frozen_string_literal: true

module TagHelper
  def fill_in_tag(name, selector = '.tagify__input')
    tag_count_before = all('.tagify__tag', visible: :all).count
    tag_input = find(selector, match: :first)
    tag_input.click
    tag_input.native.send_keys(name, :return)
    assert_selector('.tagify__tag', count: tag_count_before + 1, wait: 10, visible: :all)
    # Wait for the hidden input to be updated with the new tag (React components only)
    return unless has_selector?("input[type='hidden'][name*='tag_list']", visible: :all)

    assert_selector("input[type='hidden'][name*='tag_list'][value*='#{name}']", visible: :all, wait: 10)
  end

  def fill_in_tag_with_alert(name, selector = '.tagify__input')
    tag_input = find(selector)
    tag_input.click
    accept_alert do
      tag_input.native.send_keys(name, :return)
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

  def assert_admin_can_edit_tag(tag_path)
    visit_with_auth tag_path, 'komagata'
    assert_text('タグ名変更')
  end

  def assert_non_admin_cannot_edit_tag(tag_path)
    visit_with_auth tag_path, 'kimura'
    assert_no_text('タグ名変更')
  end

  def assert_tag_update_button_disabled_for_same_value(tag_path, tag_name)
    visit_with_auth tag_path, 'komagata'
    click_button 'タグ名変更'
    # Confirm modal is displayed
    assert_selector '.a-card.is-modal', visible: true
    # Fill in tag name field (wait for React state to update)
    fill_in('tag[name]', with: tag_name)
    # Wait for React state update and button disabled state
    assert_selector 'button:disabled', text: '変更'
  end
end
