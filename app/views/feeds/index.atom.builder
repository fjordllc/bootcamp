atom_feed(language: 'ja-JP') do |feed|
  feed.title 'みんなのブログ'
  feed.updated @entries.first.published
  @entries.each do |article|
    feed.entry(
      article,
      url:       article.url,
      id:        article.url,
      published: article.published,
      updated:   article.published
    ) do |item|
      item.title article.title
      item.content(article.content, type: 'html')
      item.author do |author|
        author.name article.author
      end
    end
  end
end
