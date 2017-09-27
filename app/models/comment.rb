class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :report
  after_create CommentCallbacks.new
  alias_method :sender, :user

  validates :description, presence: true

  def reciever
    report.user
  end
end
