# frozen_string_literal: true

require 'test_helper'

class ProductSelfAssignedNoRepliedQueryTest < ActiveSupport::TestCase
  test 'should return product self assigned no replied' do
    mentor = users(:mentormentaro)
    no_replied_product = Product.create!(
      body: 'test',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: mentor.id,
      published_at: Time.current,
      wip: false
    )

    result = ProductSelfAssignedNoRepliedQuery.new(user_id: mentor.id).call

    assert_includes result, no_replied_product
  end

  test 'should not include products where user has already replied' do
    mentor = users(:mentormentaro)

    product = Product.create!(
      body: 'already replied',
      user: users(:kimura),
      practice: practices(:practice5),
      checker_id: mentor.id,
      published_at: Time.current,
      wip: false
    )

    Comment.create!(
      commentable: product,
      user: mentor,
      description: '返信コメント'
    )

    result = ProductSelfAssignedNoRepliedQuery.new(user_id: mentor.id).call

    assert_not_includes result, product
  end

  test 'should be ordered by published_at asc' do
    mentor = users(:mentormentaro)

    result = ProductSelfAssignedNoRepliedQuery.new(user_id: mentor.id).call

    assert_equal result, result.sort_by(&:published_at)
  end
end
