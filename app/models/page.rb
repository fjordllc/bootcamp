class Page < ActiveRecord::Base
  validates :title, presence: true
  validates :body, presence: true

  def to_param
    title
  end
end
