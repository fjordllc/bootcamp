# frozen_string_literal: true

require 'test_helper'

class  ApplicationHelperTest < ActionView::TestCase
  test 'searchable_summary, comment = word' do
    comment = '検索ワード'
    word = '検索ワード'

    assert_equal '検索ワード', searchable_summary(comment, word)
  end

  test 'searchable_summary, word is ""' do
    comment = '0987654321検索ワード1234567890'
    word = ''

    assert_equal '0987654321検索ワード1234567890', searchable_summary(comment, word)
  end

  test 'searchable_summary, word is space' do
    comment = '0987654321検索ワード1234567890'
    word = ' '

    assert_equal '0987654321検索ワード1234567890', searchable_summary(comment, word)
  end

  test 'searchable_summary, word is multiple' do
    comment = '09876543210987654321098765432109876543210987654321検索ワード検索単語キーワード12345678901234567890'
    word = 'キーワード　検索ワード　単語　'

    assert_equal '09876543210987654321098765432109876543210987654321検索ワード検索単語キーワード12345678901234567890', searchable_summary(comment, word)
  end

  test 'regexp in searchable_summary' do
    comment = 'テスト! " # $ \' % & ( ) = ~ | - ^ ¥ ` { @ [ + * } ; : ] < > ? _ , . / 　テスト'
    word = '% テスト'

    assert_equal 'テスト! " # $ \' % &amp; ( ) = ~ | - ^ ¥ ` { @ [ + * } ; : ] &lt; &gt; ? _ , . / 　テスト', searchable_summary(comment, word)
  end
end
