# frozen_string_literal: true

require 'test_helper'
require 'supports/product_helper'

class DelayedUsersQueryTest < ActiveSupport::TestCase
  include ProductHelper

  test 'when there are users within 2 weeks from completion of last practice' do
    user = users(:nippounashi)
    practice1 = practices(:practice1)
    practice2 = practices(:practice2)
    today = Time.zone.today

    create_checked_product(user, practice1)
    Learning.create!(
      user:,
      practice: practice1,
      status: :complete,
      created_at: (today - 2.weeks).to_formatted_s(:db),
      updated_at: (today - 2.weeks).to_formatted_s(:db)
    )

    create_checked_product(user, practice2)
    Learning.create!(
      user:,
      practice: practice2,
      status: :complete,
      created_at: (today - (2.weeks + 1.day)).to_formatted_s(:db),
      updated_at: (today - (2.weeks + 1.day)).to_formatted_s(:db)
    )

    worried_users = DelayedUsersQuery.new.call.order(completed_at: :asc)

    assert_equal worried_users.where(id: user.id).size, 1
    assert_equal worried_users.find(user.id).id, user.id
  end

  test 'when there are users within less than 2 weeks from completion of last practice' do
    user = users(:nippounashi)
    today = Time.zone.today

    Learning.create!(
      user:,
      practice: Practice.first,
      status: :complete,
      created_at: (today - (2.weeks - 1.day)).to_formatted_s(:db),
      updated_at: (today - (2.weeks - 1.day)).to_formatted_s(:db)
    )

    worried_users = DelayedUsersQuery.new.call.order(completed_at: :asc)

    assert_equal worried_users.where(id: user.id).size, 0
  end

  test 'when there are graduate users within 2 weeks from completion of last practice' do
    user = users(:nippounashi)
    practice1 = practices(:practice1)
    today = Time.zone.today

    create_checked_product(user, practice1)
    Learning.create!(
      user:,
      practice: practice1,
      status: :complete,
      created_at: (today - 2.weeks).to_formatted_s(:db),
      updated_at: (today - 2.weeks).to_formatted_s(:db)
    )

    worried_users = DelayedUsersQuery.new.call.order(completed_at: :asc)
    assert_equal worried_users.where(id: user.id).size, 1
    assert_equal worried_users.find(user.id).id, user.id

    user.graduated_on = today
    user.save!

    worried_users = DelayedUsersQuery.new.call.order(completed_at: :asc)
    assert_equal worried_users.where(id: user.id).size, 0
  end
end
