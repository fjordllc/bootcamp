# frozen_string_literal: true

require 'test_helper'

class Grass::GrassComponentTest < ViewComponent::TestCase
  setup do
    @user = users(:sotugyou).extend(UserDecorator)
    params_date = "#{Date.current.year}-#{Date.current.month}-#{Date.current.day}"
    @target_end_date = GrassDateParameter.new(params_date).target_end_date
    @times = Grass.times(@user, @target_end_date)
    render_inline(Grass::GrassComponent.new(
                    user: @user,
                    times: @times,
                    target_end_date: @target_end_date,
                    path: :root_path
                  ))
  end

  def test_prev_year_link
    prev_year_str = @target_end_date.prev_year.to_s
    expected_path = "/?end_date=#{prev_year_str}"
    assert_selector "a[href='#{expected_path}'] .user-grass.nav__previous i.fa-solid.fa-angle-left"
  end

  def test_next_year_link
    target_end_date = Date.current.prev_year
    render_inline(Grass::GrassComponent.new(
                    user: @user,
                    times: Grass.times(@user, target_end_date),
                    target_end_date:,
                    path: :root_path
                  ))
    next_year_str = target_end_date.next_year.to_s
    expected_path = "/?end_date=#{next_year_str}"
    assert_selector "a[href='#{expected_path}'] .user-grass-nav__next i.fa-solid.fa-angle-right"
  end

  def test_next_year?
    assert_selector '.user-grass-nav__next.is-blank' if @target_end_date.next_year <= Date.current
  end
end
