# frozen_string_literal: true

require 'test_helper'

class PiyoChatMessageTest < ActiveSupport::TestCase
  test 'valid with user, section, role, and content' do
    message = piyo_chat_messages(:user_question)
    assert message.valid?
  end

  test 'role must be user or assistant' do
    message = piyo_chat_messages(:user_question)
    message.role = 'system'
    assert_not message.valid?
  end

  test 'content is required' do
    message = piyo_chat_messages(:user_question)
    message.content = ''
    assert_not message.valid?
  end

  test 'belongs to user' do
    message = piyo_chat_messages(:user_question)
    assert_equal users(:hatsuno), message.user
  end

  test 'belongs to section' do
    message = piyo_chat_messages(:user_question)
    assert_equal textbook_sections(:section_variables), message.section
  end
end
