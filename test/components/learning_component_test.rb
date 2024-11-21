# frozen_string_literal: true

require 'test_helper'

class Learnings::LearningComponentTest < ViewComponent::TestCase
  def test_render_existing_product_link
    practice = practices(:practice1)
    current_user = users(:mentormentaro)
    render_inline(Learnings::LearningComponent.new(practice:, current_user:))

    assert_link '提出物へ', href: '/products/728267494'
  end

  def test_render_new_product_link
    practice = practices(:practice1)
    current_user = users(:hatsuno)
    render_inline(Learnings::LearningComponent.new(practice:, current_user:))

    assert_link '提出物を作る', href: '/products/new?practice_id=315059988'
  end

  def test_does_not_render_product_link_when_practice_is_not_submission
    practice = practices(:practice3)
    current_user = users(:hatsuno)
    render_inline(Learnings::LearningComponent.new(practice:, current_user:))

    assert_no_link '提出物へ'
    assert_no_link '提出物を作る'
  end

  def test_render_completed_message_when_practice_is_completed
    practice = practices(:practice2)
    current_user = users(:komagata)
    render_inline(Learnings::LearningComponent.new(practice:, current_user:))

    assert_selector '.test-completed', text: '修了しています'
  end

  def test_render_complete_button_when_practice_is_not_completed
    practice = practices(:practice1)
    current_user = users(:hatsuno)
    render_inline(Learnings::LearningComponent.new(practice:, current_user:))

    assert_selector '#js-complete', text: '修了'
  end
end
