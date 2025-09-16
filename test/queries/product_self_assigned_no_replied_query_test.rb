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

  test 'test should include products where last comment is not by checker' do
    mentor = users(:mentormentaro)
    user = users(:kimura)

    product = Product.create!(
      body: 'test',
      user:,
      practice: practices(:practice5),
      checker_id: mentor.id,
      published_at: Time.current,
      wip: false
    )

    Comment.create!(
      commentable: product,
      user:,
      description: '生徒からの返信コメント'
    )

    result = ProductSelfAssignedNoRepliedQuery.new(user_id: mentor.id).call

    assert_includes result, product
  end

  test 'should be ordered by published_at asc' do
    mentor = users(:mentormentaro)
    user = users(:hajime)

    time = Time.current

    Product.create!(
      body: 'test',
      user:,
      practice: practices(:practice1),
      checker_id: mentor.id,
      published_at: time,
      wip: false
    )

    Product.create!(
      body: 'test',
      user:,
      practice: practices(:practice2),
      checker_id: mentor.id,
      published_at: time,
      wip: false
    )

    Product.create!(
      body: 'test',
      user:,
      practice: practices(:practice3),
      checker_id: mentor.id,
      published_at: time,
      wip: false
    )

    result = ProductSelfAssignedNoRepliedQuery.new(user_id: mentor.id).call

    assert_equal(result, result.sort_by { |p| [p.published_at, p.id] })
  end
end
