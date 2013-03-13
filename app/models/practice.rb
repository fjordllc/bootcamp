class Practice < ActiveRecord::Base
  validates :title, presence: true
  validates :description, presence: true

  def rendering
    Redcarpet::Markdown.new(
      Redcarpet::Render::HTML,
      no_intra_emphasis:   true,
      fenced_code_blocks:  true,
      autolink:            true,
      tables:              true,
      superscript:         true,
      space_after_headers: true
    ).render(self.description)
  end
end
