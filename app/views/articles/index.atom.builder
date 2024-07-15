atom_feed do |feed|
  feed.title("ブログ | FJORD BOOT CAMP（フィヨルドブートキャンプ）")
  feed.updated(@atom_articles.first.created_at)
  @atom_articles.each do |article|
    feed.entry(article) do |entry|
      entry.title(article.title)
      summary_html = md2html(article.summary)
      entry.summary(summary_html, type: 'html')
      body_html = md2html(article.body)
      entry.content(body_html, type: 'html')

      entry.author do |author|
        author.name(article.user.login_name)
      end
    end
  end
end
