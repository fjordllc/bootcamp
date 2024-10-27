# frozen_string_literal: true

require 'test_helper'

class BookTest < ActiveSupport::TestCase
  test '#coursebook?' do
    course1_practices = [practices(:practice1), practices(:practice2), practices(:practice3), practices(:practice57)]
    course3_practices = [practices(:practice51), practices(:practice16), practices(:practice17), practices(:practice19)]

    assert books(:book1).coursebook?(course1_practices)
    assert_not books(:book4).coursebook?(course3_practices)
  end

  test '.filtered_books' do
    book1 = Book.create!(
      title: 'ゼロからわかるRuby超入門',
      price: '2592',
      page_url: 'https://www.amazon.co.jp/dp/B07KQXFF6D',
      created_at: Time.zone.local(2022, 10, 31),
      updated_at: Time.zone.local(2022, 10, 31)
    )
    book2 = Book.create!(
      title: 'パーフェクト Ruby on Rails',
      price: '3637',
      page_url: 'https://www.amazon.co.jp/dp/B08D3DW7LP',
      created_at: Time.zone.local(2023, 11, 1),
      updated_at: Time.zone.local(2023, 11, 1)
    )
    book3 = Book.create!(
      title: '新しいLinuxの教科書',
      price: '2822',
      page_url: 'https://www.amazon.co.jp/dp/B072K1NH76',
      created_at: Time.zone.local(2024, 4, 1),
      updated_at: Time.zone.local(2024, 4, 1)
    )

    PracticesBook.create!(practice: practices(:practice1), book: book1, must_read: true)
    PracticesBook.create!(practice: practices(:practice1), book: book2)
    PracticesBook.create!(practice: practices(:practice5), book: book3, must_read: true)

    all_book = [book3, book2, book1]
    must_read = [book3, book1]

    assert_equal all_book, Book.filtered_books(nil, courses(:course1)).last(3)
    assert_equal must_read, Book.filtered_books('mustread', courses(:course1)).last(2)
  end
end
