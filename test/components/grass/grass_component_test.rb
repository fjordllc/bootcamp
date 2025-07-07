# frozen_string_literal: true

require 'test_helper'

class Grass::GrassComponentTest < ViewComponent::TestCase
  setup do
    @user = users(:sotugyou).extend(UserDecorator)
    params_date = "#{Date.current.year}-#{Date.current.month}-#{Date.current.day}"
    @target_end_date = GrassDateParameter.new(params_date).target_end_date
    @prev_year = @target_end_date.prev_year
  end

  def test_prev_year_link
    render_inline(Grass::GrassComponent.new(
                    user: @user,
                    times: Grass.times(@user, @target_end_date),
                    target_end_date: @target_end_date,
                    path: :root_path
                  ))
    prev_year_str = @prev_year.to_s
    expected_path = "/?end_date=#{prev_year_str}"
    assert_selector "a[href='#{expected_path}'] .user-grass-nav__previous i.fa-solid.fa-angle-left"
  end

  def test_next_year_link
    render_inline(Grass::GrassComponent.new(
                    user: @user,
                    times: Grass.times(@user, @target_end_date),
                    target_end_date: @prev_year,
                    path: :root_path
                  ))
    next_year_str = @prev_year.next_year.to_s
    expected_path = "/?end_date=#{next_year_str}"
    assert_selector "a[href='#{expected_path}'] .user-grass-nav__next i.fa-solid.fa-angle-right"
  end

  def test_next_year_navigation_disabled_when_current_year
    render_inline(Grass::GrassComponent.new(
                    user: @user,
                    times: Grass.times(@user, @target_end_date),
                    target_end_date: @target_end_date,
                    path: :root_path
                  ))
    assert_selector '.user-grass-nav__next.is-blank'
  end
end
