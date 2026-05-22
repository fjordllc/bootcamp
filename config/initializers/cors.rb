Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # 紹介・言及記事を収集するためのChrome拡張です。
    origins "chrome-extension://ddobgcfepfdpccmgnpfgjcomccpkcdjj"
    resource "/api/*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
