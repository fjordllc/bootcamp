# frozen_string_literal: true

require 'application_system_test_case'

module Answers
  class BestAnswerTest < ApplicationSystemTestCase
    include ActiveJob::TestHelper

    setup do
      @delivery_mode = AbstractNotifier.delivery_mode
      AbstractNotifier.delivery_mode = :normal
    end

    teardown do
      AbstractNotifier.delivery_mode = @delivery_mode
    end

    test "admin can resolve user's question" do
      visit_with_auth "/questions/#{questions(:question2).id}", 'komagata'
      assert_text 'ベストアンサーにする'
      accept_alert do
        click_button 'ベストアンサーにする'
      end
      assert_no_text 'ベストアンサーにする'
    end

    test 'delete best answer' do
      visit_with_auth "/questions/#{questions(:question2).id}", 'komagata'
      accept_alert do
        click_button 'ベストアンサーにする'
      end
      accept_alert do
        click_button 'ベストアンサーを取り消す'
      end
      assert_text 'ベストアンサーにする'
    end

    test 'notify watchers of best answer' do
      visit_with_auth "/questions/#{questions(:question2).id}", 'sotugyou'

      assert_difference 'ActionMailer::Base.deliveries.count', 1 do
        perform_enqueued_jobs do
          assert_no_text '解決済'
          accept_alert do
            click_button 'ベストアンサーにする'
          end
          assert_text '解決済'
        end
      end

      # Watcherに通知される
      visit_with_auth '/notifications?status=unread', 'kimura'
      assert_text 'sotugyouさんの質問【 injectとreduce 】でkomagataさんの回答がベストアンサーに選ばれました。'

      # Watchしていない回答者には通知されない
      visit_with_auth '/notifications?status=unread', 'komagata'
      assert_no_text 'sotugyouさんの質問【 injectとreduce 】でkomagataさんの回答がベストアンサーに選ばれました。'

      # 質問者には通知されない
      visit_with_auth '/notifications?status=unread', 'sotugyou'
      assert_no_text 'sotugyouさんの質問【 injectとreduce 】でkomagataさんの回答がベストアンサーに選ばれました。'
    end
  end
end
