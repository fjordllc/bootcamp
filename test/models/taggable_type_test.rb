# frozen_string_literal: true

require 'test_helper'

class TaggableTypeTest < ActiveSupport::TestCase
  test 'resolve returns the class for supported tagging target types' do
    { 'User' => User, 'Page' => Page, 'Movie' => Movie, 'Question' => Question, 'Article' => Article }.each do |type, klass|
      assert_equal klass, TaggableType.resolve(type)
    end
  end

  test 'resolve returns nil for unsupported tagging target types' do
    ['Report', 'Kernel', 'Object', 'UnknownResource', '', ' ', 'user', ' User', 'User ', '::User', '123',
     :User, ['User'], { name: 'User' }, 123, false, nil].each do |type|
      assert_nil TaggableType.resolve(type), "Unexpected resolution for #{type.inspect}"
    end
  end
end
