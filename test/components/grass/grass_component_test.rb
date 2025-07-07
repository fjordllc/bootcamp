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
    expected_path = "/?end_date=#{@prev_year.to_s}"
    assert_selector "a[href='#{expected_path}'] .user-grass-nav__previous i.fa-solid.fa-angle-left"
  end

  def test_next_year_link
    render_inline(Grass::GrassComponent.new(
                    user: @user,
                    times: Grass.times(@user, @target_end_date),
                    target_end_date: @prev_year,
                    path: :root_path
                  ))
    next_year = @prev_year.next_year
    expected_path = "/?end_date=#{next_year.to_s}"
    assert_selector "a[href='#{expected_path}'] .user-grass-nav__next i.fa-solid.fa-angle-right"
  end

  def test_next_year_navigation_disabled_when_current_year
    render_inline(Grass::GrassComponent.new(
                    user: @user,
                    times: Grass.times(@user, @target_end_date),
                    target_end_date: @target_end_date,
                    path: :root_path
                  ))
    assert_selector '.user-grass-nav__next.is-blank' if @target_end_date.next_year <= Date.current
  end
end
