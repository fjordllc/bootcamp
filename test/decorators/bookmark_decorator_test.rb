# frozen_string_literal: true

require 'test_helper'

class BookmarkDecoratorTest < ActiveSupport::TestCase
  def setup
    @bookmark30 = ActiveDecorator::Decorator.instance.decorate(bookmarks(:bookmark30))
    @bookmark29 = ActiveDecorator::Decorator.instance.decorate(bookmarks(:bookmark29))
    @bookmark28 = ActiveDecorator::Decorator.instance.decorate(bookmarks(:bookmark28))
    @bookmark27 = ActiveDecorator::Decorator.instance.decorate(bookmarks(:bookmark27))
  end

  test '#display_date' do
    assert_equal I18n.l(bookmarks(:bookmark30).bookmarkable.created_at), I18n.l(@bookmark30.display_date)
    assert_equal I18n.l(bookmarks(:bookmark29).bookmarkable.created_at), I18n.l(@bookmark29.display_date)
    assert_equal I18n.l(bookmarks(:bookmark28).bookmarkable.created_at), I18n.l(@bookmark28.display_date)
    assert_equal I18n.l(bookmarks(:bookmark27).bookmarkable.reported_on), I18n.l(@bookmark27.display_date)
  end
end
