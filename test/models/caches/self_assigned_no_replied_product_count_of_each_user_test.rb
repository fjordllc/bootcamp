# frozen_string_literal: true

require 'test_helper'

class SelfAssignedNoRepliedProductCountOfEachUserTest < ActiveSupport::TestCase
  test "cached count of a mentor's unreplied products increases by 1 after the mentor gets assigned to a product" do
    mentor = users(:machida)
    unassigned_product = Product.not_wip.unassigned.first

    assert_difference "Cache.self_assigned_no_replied_product_count(#{mentor.id})", 1 do
      unassigned_product.update!(checker: mentor)
    end
  end

  test "cached count of a mentor's unreplied products decreases by 1 after the mentor gets unassigned from an unreplied product" do
    mentor_id = users(:machida).id
    assigned_and_unreplied_product = Product.self_assigned_no_replied_products(mentor_id).first

    assert_difference "Cache.self_assigned_no_replied_product_count(#{mentor_id})", -1 do
      assigned_and_unreplied_product.update!(checker: nil)
    end
  end

  test "cached count of a mentor's unreplied products decreases by 1 after the mentor comments to an unreplied product" do
    mentor = users(:machida)
    assigned_and_unreplied_product = Product.self_assigned_no_replied_products(mentor.id).first

    assert_difference "Cache.self_assigned_no_replied_product_count(#{mentor.id})", -1 do
      # 「担当が未返信」の提出物を「担当が返信済み」の状態にする
      assigned_and_unreplied_product.comments.create!(description: '担当者が提出物へ返信', user: mentor)
    end
  end

  test "cached count of a mentor's unreplied products increases by 1 after another user comments to a mentor's replied product" do
    mentor = users(:machida)
    assigned_and_replied_product = Product.self_assigned_and_replied_products(mentor.id).first

    assert_difference "Cache.self_assigned_no_replied_product_count(#{mentor.id})", 1 do
      # 「担当が返信済み」の提出物を「担当が未返信」の状態にする
      assigned_and_replied_product.comments.create!(description: '担当者以外のユーザーが提出物へ返信', user: users(:komagata))
    end
  end

  test "cached count of a mentor's unreplied products decreases by 1 when the mentor's comment becomes latest after destroying the latest comment" do
    mentor = users(:machida)
    assigned_and_replied_product = Product.self_assigned_and_replied_products(mentor.id).first
    latest_comment_from_another_user = assigned_and_replied_product.comments.create!(description: '担当者以外のユーザーが提出物へ返信', user: users(:komagata))

    assert_difference "Cache.self_assigned_no_replied_product_count(#{mentor.id})", -1 do
      # 「担当が未返信」の提出物を「担当が返信済み」の状態にする
      latest_comment_from_another_user.destroy!
    end
  end

  test "cached count of a mentor's unreplied products increases by 1 when the mentor's comment is no longer the latest after destroying the latest comment" do
    mentor = users(:machida)
    assigned_and_unreplied_product = Product.self_assigned_no_replied_products(mentor.id).first
    latest_comment_from_mentor = assigned_and_unreplied_product.comments.create!(description: '担当者が提出物へ返信', user: mentor)

    assert_difference "Cache.self_assigned_no_replied_product_count(#{mentor.id})", 1 do
      # 「担当が返信済み」の提出物を「担当が未返信」の状態にする
      latest_comment_from_mentor.destroy!
    end
  end
end
