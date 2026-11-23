# frozen_string_literal: true

module TagHelper
  def close_header_dropdowns
    page.execute_script(<<~JS)
      document.querySelectorAll('.is-opened-dropdown').forEach((element) => {
        element.classList.remove('is-opened-dropdown')
      })
    JS
  end

  def click_tag_edit
    close_header_dropdowns
    page.execute_script('arguments[0].click()', find('.tag-links__item-edit'))
  end

  def click_tag_name_change
    close_header_dropdowns
    page.execute_script('arguments[0].click()', first('.change-tag-name-button'))
  end

  def click_save_tag_name_change
    close_header_dropdowns
    button = find('.edit-tag-modal:not(.hidden) .save-tag-button')
    page.execute_script('arguments[0].click()', button)
  end

  def fill_in_open_tag_modal(name)
    input = find('.edit-tag-modal:not(.hidden) input[name="tag[name]"]')
    page.execute_script(<<~JS, input, name)
      const input = arguments[0]
      input.value = arguments[1]
      input.dispatchEvent(new Event('input', { bubbles: true }))
      input.dispatchEvent(new KeyboardEvent('keyup', { bubbles: true }))
    JS
  end

  def click_save_tags
    close_header_dropdowns
    page.execute_script('arguments[0].click()', find_button('保存する'))
  end

  def fill_in_tag(name, selector = '.tagify__input')
    tag_input = find(selector, match: :first)
    tag_count_before = all('.tagify__tag', visible: :all, wait: 0).count
    page.execute_script('arguments[0].click()', tag_input)
    tag_input.send_keys(name, :return)
    assert_selector('.tagify__tag', count: tag_count_before + 1, wait: 10, visible: :all)
    # Wait for the hidden input to be updated with the new tag (React components only)
    return unless has_selector?("input[type='hidden'][name*='tag_list']", visible: :all, wait: 0)

    assert_selector("input[type='hidden'][name*='tag_list'][value*='#{name}']", visible: :all, wait: 10)
  end

  def fill_in_tag_with_alert(name, selector = '.tagify__input')
    tag_input = find(selector)
    page.execute_script('arguments[0].click()', tag_input)
    accept_alert do
      tag_input.send_keys(name, :return)
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

  def assert_non_admin_cannot_edit_tag(tag_path)
    visit_with_auth tag_path, 'kimura'
    assert_no_text('タグ名変更')
  end
end
