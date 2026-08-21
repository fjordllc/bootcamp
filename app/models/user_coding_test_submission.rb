# frozen_string_literal: true

class UserCodingTestSubmission
  def initialize(user)
    @user = user
  end

  def submitted?(coding_test)
    @user.coding_test_submissions.exists?(coding_test_id: coding_test.id)
  end
end
