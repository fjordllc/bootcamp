# frozen_string_literal: true

require 'test_helper'

class CheckCallbacksTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    @checker = users(:komagata)
    @practice = practices(:practice47)
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'notifies the author when the product is checked' do
    product = Product.create!(body: 'test', user: users(:kimura), practice: @practice, checker_id: @checker.id)

    perform_enqueued_jobs { Check.create!(user: @checker, checkable: product) }

    assert_equal ["komagataさんが「#{@practice.title}」の提出物を合格にしました。"], checked_messages(users(:kimura), product)
  end

  test 'trainee and advisers receive different wording when the product is checked' do
    product = Product.create!(body: 'test', user: users(:kensyu), practice: @practice, checker_id: @checker.id)

    perform_enqueued_jobs { Check.create!(user: @checker, checkable: product) }

    assert_equal ["komagataさんが「#{@practice.title}」の提出物を合格にしました。"], checked_messages(users(:kensyu), product)
    assert_equal ["komagataさんがkensyuさんの「#{@practice.title}」の提出物を合格にしました。"], checked_messages(users(:senpai), product)
  end

  private

  def checked_messages(user, product)
    Notification.where(user:, kind: :checked, link: "/products/#{product.id}").map(&:message)
  end
end
