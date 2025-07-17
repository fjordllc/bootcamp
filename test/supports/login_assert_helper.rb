# frozen_string_literal: true

module LoginAssertHelper
  def assert_login_required(path)
    retry_count = 0
    max_retries = 3

    begin
      visit path

      # まずbodyがロードされるのを待つ
      assert_selector 'body'

      assert_text 'ログインしてください'
      assert_selector 'h1', text: 'プラス戦力のスキルを身につける'
    rescue Net::ReadTimeout, Errno::ECONNRESET, Capybara::ElementNotFound => e
      retry_count += 1
      if retry_count <= max_retries
        puts "Retrying due to #{e.class}: #{e.message} (attempt #{retry_count}/#{max_retries})"
        sleep(retry_count * 0.5) # Exponential backoff
        retry
      else
        raise e
      end
    end
  end

  def assert_no_login_required(path, text)
    retry_count = 0
    max_retries = 3

    begin
      visit path

      # まずbodyがロードされるのを待つ
      assert_selector 'body'

      assert_text text
      assert_no_text 'ログインしてください'
    rescue Net::ReadTimeout, Errno::ECONNRESET, Capybara::ElementNotFound => e
      retry_count += 1
      if retry_count <= max_retries
        puts "Retrying due to #{e.class}: #{e.message} (attempt #{retry_count}/#{max_retries})"
        sleep(retry_count * 0.5) # Exponential backoff
        retry
      else
        raise e
      end
    end
  end
end
