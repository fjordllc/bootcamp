# frozen_string_literal: true

require 'test_helper'

class ProductCheckerNotifierTest < ActiveSupport::TestCase
  def setup
    @product = products(:product64)
    @current_user = users(:komagata)
    @checker = users(:kimura)
  end

  test 'Notify if the designated contact person changes' do
    @product.checker = @checker
    @product.save!

    delivery = Minitest::Mock.new
    delivery.expect(:notify, nil, [:assigned_as_checker])

    ActivityDelivery.stub(:with, delivery) do
      ProductCheckerNotifier.new(@product, @current_user).call
    end

    delivery.verify
  end

  test 'Do not notify if the designated contact person has not changed' do
    ActivityDelivery.stub(:with, ->(**) { flunk 'ActivityDelivery.withが呼び出されました' }) do
      ProductCheckerNotifier.new(@product, @current_user).call
    end
  end

  test 'Notify checker when product is published from WIP' do
    @product.update!(wip: true, checker: @checker)
    @product.update!(wip: false)

    delivery = Minitest::Mock.new
    delivery.expect(:notify, nil, [:assigned_as_checker])

    ActivityDelivery.stub(:with, delivery) do
      ProductCheckerNotifier.new(@product, @current_user).call
    end

    delivery.verify
  end
end
