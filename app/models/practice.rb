class Practice < ActiveRecord::Base
  before_validation :rendering
  validates :title, presence: true

  protected
    def rendering
      self.description = Redcarpet::Markdown.new(
        Redcarpet::Render::HTML,
        no_intra_emphasis:   true,
        fenced_code_blocks:  true,
        autolink:            true,
        tables:              true,
        superscript:         true,
        space_after_headers: true
      ).render(self.draft) if self.draft.present?
    end
end
